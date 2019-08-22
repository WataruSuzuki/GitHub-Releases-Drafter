swift build -c release

cd .build/release
zip GitHubReleasesDrafter.zip GitHubReleasesDrafter
cd -
mv .build/release/GitHubReleasesDrafter.zip ./

.build/debug/GitHubReleasesDrafter $1 \
    --path "WataruSuzuki/GitHub-Releases-Drafter" \
    --token $PUBLISH_TOKEN \
    --assetFileName "GitHubReleasesDrafter.zip"
