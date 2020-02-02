## Packaging the app for the App Store

1. Modify icon-1024.png to your own icon.

2. Open Root.entitlements and make any entitlements additions/changes

3. Open */example-desktop/packaging/sign_store.sh* and modify the values at the top of the file to your own.

4. Copy your .provisionprofile into */example-desktop/mac_packaging* and rename as *AppStoreDeveloper.provisionprofile*

5. From the Teminal cd into */example-desktop/mac_packaging* and run:

```shell
bash /full/path/to/WebViewANE/example-desktop-complete/mac_packaging/sign_store.sh
```
