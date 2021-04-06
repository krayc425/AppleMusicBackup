# AppleMusicBackup

This repo can help you backup your Apple Music library, and transfer them from one Apple ID to another.

# Usage

1. Click **Get Songs** to fetch a list of your Apple Music library songs.
2. Click **Save to File** to save the `.txt` file of the list of song ids to a place (like iCloud Drive).
3. Sign in another Apple ID, click **Import from File** and select the file from `2.` to import these songs into your current library.

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
7. Remember to generate a new token after 24 hour expiration time.

# TODO

* Handle `Too Many Requests (429)` errors.