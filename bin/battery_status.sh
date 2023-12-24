#!/usr/bin/env bash
# Filters out and prettifies battery information
upower --dump | awk '
  /Device/ {
    device[++devices_cnt]["name"] = substr($0, 41);
    i = 1;
  }

  /(energy|state|percentage|time to)/ { device[devices_cnt][i++] = $0 }

  /model/ {
    split($0, a);

    for (k in a)
      if (!(tolower(a[k]) ~ /model:/))
        device[devices_cnt]["model"] = device[devices_cnt]["model"] " " a[k];
  }

  END {
    for (dev in device) {
      if (length(device[dev]["model"]) > 0)
        printf "====%s :: %s ========\n",
             device[dev]["model"], device[dev]["name"];
      else
        printf "==== %s ========\n", device[dev]["name"];

      asort(device[dev]);

      for (i in device[dev]) {
        is_name  = (tolower(device[dev][i]) ~ /(device|model)/);
        is_label = (device[dev][i] ~ /:/);

        if (!is_name && is_label)
          printf "%s\n", device[dev][i];
      }
    }
  }
'
