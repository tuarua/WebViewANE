#### Resigning for App Store Submission


1. Disconnect and power off any connected iOS devices
2. Ensure Xcode 8.3 is your default Xcode (Xcode 9 is not yet supported)
2. Package AIR app for "Apple App Store Distribution" in IDE
3. Edit resign.sh and set values for IPA, PROVISIONING_PROFILE & SIGNING_IDENTITY
4. Using Terminal: 

    ```bash
    cd [this directory]
    bash resign.sh
    ```
5. Upload the resulting ipa to the App Store using Application Loader

