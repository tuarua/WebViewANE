## Packaging the app for the App Store

1. Modify icon-1024.png to your own icon.

2. Open Root.entitlements and make any entitlements additions/changes

3. Open */mac_installer/sign_store.sh* and modify the values at the top of the file to your own.

4. Copy your .provisionprofile into */mac_installer* and rename as *AppStoreDeveloper.provisionprofile*

5. From the Teminal cd into */mac_installer* and run:

```shell
bash sign_store.sh
```

## Packaging a Notarized app for Self Distribution

1. Modify icon-1024.png to your own icon.

2. Open Root.entitlements and make any entitlements additions/changes

3. Open */mac_installer/sign_developerId.sh* and modify the values at the top of the file to your own.

4. Copy your .provisionprofile into */mac_installer* and rename as *DeveloperIdApplication.provisionprofile*

5. From the Teminal cd into */mac_installer* and run:

```shell
bash sign_developerId.sh
```
