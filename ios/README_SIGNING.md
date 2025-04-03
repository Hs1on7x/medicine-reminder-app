# iOS Code Signing Guide for Codemagic

This guide will help you set up iOS code signing in Codemagic for your Medicine Reminder app.

## Prerequisites

1. **Apple Developer Account** - You need a paid Apple Developer account
2. **Client Device UDID** - You need the UDID of your client's iPhone 14 Pro Max
3. **Codemagic Account** - Make sure you have access to your project on Codemagic.io

## Step 1: Get Your Client's Device UDID

1. Ask your client to visit [UDID.io](https://get.udid.io) on their iPhone
2. They should follow the instructions to install a profile
3. The website will display their UDID which they should share with you
4. Alternatively, they can connect to a Mac with iTunes/Finder and find the UDID by clicking on the Serial Number

## Step 2: Register the Device in Apple Developer Portal

1. Log in to [Apple Developer Portal](https://developer.apple.com)
2. Go to "Certificates, IDs & Profiles" → "Devices" → "+" button
3. Add the device with a descriptive name (e.g., "Client iPhone 14 Pro Max") and paste the UDID
4. Save the device

## Step 3: Configure Codemagic for iOS Signing

1. Go to Codemagic.io and select your medicine-reminder-app
2. Go to "Team settings" → "Integrations" → "App Store Connect"
3. Set up API access by adding:
   - API Key ID
   - Issuer ID
   - API Private Key (download from Apple)

4. Add these values to your environment variables:
   - `APP_STORE_CONNECT_KEY_IDENTIFIER` - Your API Key ID
   - `APP_STORE_CONNECT_ISSUER_ID` - Your Issuer ID
   - `APP_STORE_CONNECT_PRIVATE_KEY` - Your private key content

## Step 4: Run the iOS Workflow

1. Start a new build using the `ios-adhoc-workflow`
2. Codemagic will:
   - Create a new provisioning profile including your client's device
   - Sign the app with this profile
   - Build an IPA file that can be installed on your client's device

## Step 5: Distribute via Diawi

1. Download the IPA file from Codemagic artifacts
2. Upload to [Diawi](https://www.diawi.com/)
3. Send the link to your client
4. They can now install the app directly on their device

## Troubleshooting

If you encounter issues:

1. **Missing Mobileprovision** - Make sure your codemagic.yaml is configured for ad-hoc distribution
2. **Installation Fails** - Verify the device UDID is registered and included in the provisioning profile
3. **Build Errors** - Check Codemagic logs for specific signing errors

Remember that iOS code signing is complex, but once set up correctly, you can reuse the configuration for future builds.