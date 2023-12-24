# GnuPG
Key files are a secure method for certifying credentials digitally. Everything
is stored in `~/.gnupg` and controlled through `gpg`. It's quite complicated...
See `tldr gpg` for encryption, [devhints](https://devhints.io/gnupg) for a
cheat sheet, the [Archwiki](https://wiki.archlinux.org/title/GnuPG) for a
technical explanation and the [Debian wiki](https://wiki.debian.org/Subkeys) for
a newbie-friendly one

Terminology:

 * Public key - The one to share
 * Private key - The one to not share
 * Primary key - ??
 * Subkey - ??
 * Keygrip - The name of the key file
 * Key ID - The last few (8-16) characters of a fingerprint
 * Fingerprint - A unique identifier for a key
 * Keyring - Your entire collection of public or private keys
 * User ID - Email, part of name, Key ID, or Fingerprint of a key

Consider this example output:
```bash
 $ gpg --list-secret-keys --with-subkey-fingerprint --with-keygrip --keyid-format=long

# ///--- Short for "secret key". It's "pub" for public keys
# vvv           vvvvvvvvvvvvvvvv Key ID
> sec   ed25519/ABCDEFG123456789 4040-04-04 [SC] [expires: 4040-04-04]
>       DDEEDF222222222222222222ABCDEFG123456789
#                               ^^^^^^^^^^^^^^^^ Key ID also here
#       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fingerprint
>       Keygrip = DDEBBA3482394AEE23432DEE32432BB2432432EE
# Key is ~/.gnupg/private-keys-v1.d/DDEBBA3482394AEE23432DEE32432BB2432432EE.key
> uid                 [ultimate] Emiliko Mirror <emiliko@mami2.moe>
# ///--- Short for "secret subkey". It's "sub" for public subkeys
# vvv           vvvvvvvvvvvvvvvv Key ID
> ssb   cv25519/987654321ABCDEED 4040-04-04 [E] [expires: 4040-04-04]
>       32423BDDAAAAAAAAAAAAAAAA987654321ABCDEED
#                               ^^^^^^^^^^^^^^^^ Key ID also here
#       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fingerprint from --with-subkey-fingerprint
>       Keygrip = 2493ADDEDDDFEFEFE23432432FDEEFDD24324232
# Key is ~/.gnupg/private-keys-v1.d/2493ADDEDDDFEFEFE23432432FDEEFDD24324232.key
```

Providing the `--fingerprint` flag will alter the output slightly, tho it's the
same fingerprint, for example:

```bash
> sec   ed25519/ABCDEFG123456789 4040-04-04 [SC] [expires: 4040-04-04]
>       Key fingerprint = DDEE DF22 2222 2222 2222  2222 ABCD EFG1 2345 6789
#                                     Key ID is now here ^^^^^^^^^^^^^^^^^^^
>       Keygrip = DDEBBA3482394AEE23432DEE32432BB2432432EE
> uid                 [ultimate] Emiliko Mirror <emiliko@mami2.moe>
> ssb   cv25519/987654321ABCDEED 4040-04-04 [E] [expires: 4040-04-04]
>       Key fingerprint = 3242 3BDD AAAA AAAA AAAA  AAAA 9876 5432 1ABC DEED
#                                     Key ID is now here ^^^^^^^^^^^^^^^^^^^
>       Keygrip = 2493ADDEDDDFEFEFE23432432FDEEFDD24324232
```

## Creating a new key
This closely follows the Archwiki, with an elliptic cipher

```
gpg --full-gen-key --expert
 > (9) ECC and ECC
 > (1) Curve 25519
 > 1y  # Optional, 1 year is recommended
 > Your Name          # This will be visible in the public key
 > emiliko@mami2.moe  # This is also visible in the public key
 > No comment
 > Put a password on the primary key
```

## Signing and verification
Git commits, binaries and really any file can be signed by a private key to
prove authenticity of the file. For github, you'll need to paste your public key
to your profile settings

```bash
gpg --list-secret-keys --keyid-format=long
gpg --armor --export <user-id> | wl-copy
```

Git commits aren't signed by default. Either explicitly sign at commit time,
with `git commit -S`, or add the following to your ~/.gitconfig. If the signing
key you specify is a subkey, add an ! mark at the end

```toml
[user]
name = Emiliko Mirror
email = emiliko@mami2.moe
signingkey = ABCDEF1234567890
[commit]
gpgsign = true
```

## Encryption
Gpg can encrypt pretty much anything. Consider bundling into a tarball
beforehand if it's more than one file

The `-a/--armor` flag will make sure the encrypted file is made up entirely of
ascii characters, which is easier to copy/paste than binary nonsense

Encryption can be symmetric or asymmetric. Symmetric encryption uses 1 key and a
password to encrypt. To decrypt, use the same key and re-enter the same
password

### Symmetric encryption
Symmetric encryption uses 1 key and 1 password to encrypt. To decrypt, you'll
need the same key and the same password

### Asymmetric encryption
Asymmetric encryption is meant for sending to a specific receiver. It uses 1
public key to encrypt. To decrypt, you'll need the private key pair to that
public key. `pass` uses this one

```bash
gpg -e -o encrypted_file -r emiliko@mami2.moe secret_file
# Then emiliko can decrypt it with her private key
gpg -d -o secret_file encrypted_file
```

## Moving keys
You'll want to export your keys to other devices. Ideally, you'd only export
subkeys and not the primary key. The primary key should be stored offline and
used to generate revocation certificates for compromised subkeys

```bash
gpg -o pub_key.pgp -a --export emiliko@mami2.moe
gpg -o sec_key.pgp -a --export-secret-key emiliko@mami2.moe

scp pub_key.gpg emiliko@192.168.0.1:/tmp/safe_directory
scp sec_key.gpg emiliko@192.168.0.1:/tmp/safe_directory

gpg --import pub_key.gpg
gpg --import sec_key.gpg

```
A safer method skips the creation of any intermediary files by sending it
through ssh right away

```bash
gpg --export-secret-key <user-id> | ssh emiliko@192.168.0.1 'gpg --import'
# Or if you're on the receiving system
ssh emiliko@192.168.0.1 'gpg --export-secret-key emiliko@mami2.moe' | gpg --import
```

In either case, or actually whenever importing your keys, you'll need to edit
the trust level after importing it

```bash
gpg --list-keys  # Get the Key ID here
gpg --edit-key <user-id>
> trust
> 5 # If it's your own key
> y
> quit
```

For use with `pass`, you can check if your encryption key is working by trying
to add a new password, like `pass insert -e something` and see if it succeeds

## Backing up keys
Keys should be backed up on offline, physically inaccessible, media. Usb sticks
you leave at home or a piece of paper are both good choices. For the paper
version see `paperkey`

```bash
gpg -o /run/media/my_usb/keys.gpg --export-options backup --export-secret-keys emiliko@mami2.moe
```

Now later, or on another device, you can restore these keys

```bash
gpg --import-options restore --import keys.gpg
```

Then edit the trust level, as with the other transfer methods
