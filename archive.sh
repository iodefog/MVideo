log_path="log_path.txt"
workspaceName="MVideo.xcworkspace"
scheme="MVideo"
configurationBuildDir="MVideo/build"
codeSignIdentity="iPhone Distribution: BEIJING SOHU NEW MEDIA INFORMATION TECHNOLOGY CO. Ltd."
adHocProvisioningProfile="iPhoneVideo Inhouse"
appStoreProvisioningProfile="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
configuration="Debug"
archivePath="./MVideo.xcarchive"
# xcodebuild clean -configuration "$configuration" -alltargets >> $log_path
xcodebuild archive -workspace "$workspaceName" -scheme "$scheme" -configuration "$configuration" -archivePath "$archivePath" CONFIGURATION_BUILD_DIR="$configurationBuildDir"
 # CODE_SIGN_IDENTITY="$codeSignIdentity" PROVISIONING_PROFILE="$provisioningProfile" > $log_path
# xcodebuild -workspace "$workspaceName" -scheme "$scheme" -configuration Debug build CODE_SIGN_IDENTITY="$codeSignIdentity" 
