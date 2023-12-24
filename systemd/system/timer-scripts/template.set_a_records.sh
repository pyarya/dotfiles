#!/usr/bin/env bash
declare wan_ip_record wan_ip cf_records host_record cf_host_ip cf_rec_id

declare -r HOST=<your-subdomain>
declare -r DOMAIN=<your-domain-name>
declare -r TOKEN=<your-api-token>
declare -r ZONE_ID=<this-zones-id>

#╔─────────────────────────────────────────────────────────────────────────────╗
#│ Gετ WΛN IP                                                                  |
#╚─────────────────────────────────────────────────────────────────────────────╝
if ! wan_ip_record="$(host -W2 myip.opendns.com resolver1.opendns.com)"; then
  echo "Hosts timed out" >&2
  exit 1
fi

wan_ip="$(echo "$wan_ip_record" | tail -n1 | awk '{ split($0, a, " "); print a[4] }')"

#╔─────────────────────────────────────────────────────────────────────────────╗
#│ Gετ Λ rεcδrd δη Clδμdflαrε                                                  |
#╚─────────────────────────────────────────────────────────────────────────────╝
if ! cf_records="$(curl -s --request GET \
  --url https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $TOKEN")"
then
  echo "Failed to retrive cloudflare zone records" >&2
  exit 1
fi

for i in {0..4000}; do  # Assuming 4000 is enough
  record="$(echo "$cf_records" | jq --raw-output ".result[${i}].name")"

  if [[ "$record" == "${HOST}.${DOMAIN}" ]]; then
    host_record="$(echo "$cf_records" | jq -r ".result[${i}]")"
    break
  elif [[ "$record" == null ]]; then
    echo "No record found for ${HOST}.${DOMAIN}" >&2
    exit 1
  fi
done

#╔─────────────────────────────────────────────────────────────────────────────╗
#│ Sετ Λ rεcδrd τδ cμrrεητ WΛN                                                 |
#╚─────────────────────────────────────────────────────────────────────────────╝
cf_host_ip="$(echo "$host_record" | jq -r '.content')"
cf_rec_id="$(echo "$host_record" | jq -r '.id')"

if [[ -z "$cf_host_ip" || "$cf_host_ip" == null ]]; then
  echo "Failed to find content of A record for ${HOST}.${DOMAIN}" >&2
  exit 1
elif [[ -z "$cf_rec_id" || "$cf_rec_id" == null ]]; then
  echo "Failed to find A record ID for ${HOST}.${DOMAIN}" >&2
  exit 1
fi

if [[ "$cf_host_ip" == "$wan_ip" ]]; then
  echo "Cloudflare is up to date @ $(date)" >&2
else
  echo "Updating Cloudflare's A record from $cf_host_ip to $wan_ip" >&2

  patch_response="$(curl -s --request PATCH \
      --url "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${cf_rec_id}" \
      --header 'Content-Type: application/json' \
      --header "Authorization: Bearer $TOKEN" \
      --data '{
      "comment": "'"${HOST} @ $(date)"'",
      "content": "'"$wan_ip"'",
      "name": "'"${HOST}.${DOMAIN}"'",
      "proxied": false,
      "ttl": 1
    }')"

  if [[ "$(echo "$patch_response" | jq -r '.success')" == true ]]; then
    echo "Update to $wan_ip succeeded @ $(date)" >&2
  else
    echo "Failed to update A record. DUMP:"
    echo "$patch_response"
    exit 1
  fi
fi
