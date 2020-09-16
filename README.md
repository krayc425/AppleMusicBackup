# AppleMusicBackup

To backup your Apple Music library, and transfer from one Apple ID to another.

# Steps

1. Follow steps [here](https://help.apple.com/developer-account/#/devce5522674) to generate a `MusicKit identifier` and a private `.p8` key file.
2. Install `pip` if you haven't.
3. Install these two packages.
```Sh
sudo pip install pyjwt
sudo pip install cryptography
```
4. Copy your `Developer Team ID`, `MusicKit ID` and private key in the `.p8` file into `musictoken.py`.
5. Run `python(3) musictoken.py`
6. Copy the generated token to `AppleMusicBackup/DeveloperToken.swift`.
