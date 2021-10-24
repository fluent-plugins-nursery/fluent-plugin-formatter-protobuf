# Release

## Instructions
To release the gem to Github package manager and Ruby Gems,

1. Update `lib/fluent/plugin/version.rb`
2. Create a pull request and merge it into `main`
3. Manually creating a release on Github with a tag indicating the new version number e.g. `vMAJOR.MINOR.PATCH`
4. GitHub Actions will automatically run and publish to RubyGems and GitHub repository
