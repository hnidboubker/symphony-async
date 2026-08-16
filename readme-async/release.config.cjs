module.exports = {
  branches: ['main'],

  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',

    [
      '@semantic-release/changelog',
      {
        changelogFile: 'CHANGELOG.md',
      },
    ],

    [
      '@semantic-release/exec',
      {
        prepareCmd: 'npm version ${nextRelease.version} --no-git-tag-version',
      },
    ],

    [
      '@semantic-release/git',
      {
        assets: [
          'package.json',
          'package-lock.json',
          'CHANGELOG.md',
        ],
        message: 'chore(release): ${nextRelease.version} [skip ci]',
      },
    ],

    [
      '@semantic-release/github',
      {
        successComment: false,
        failComment: false,
      },
    ],
  ],
};