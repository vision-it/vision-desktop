# vision-desktop

[![Build Status](https://travis-ci.com/vision-it/vision-desktop.svg?branch=production)](https://travis-ci.com/vision-it/vision-desktop)

## Parameter

## Usage

Include in the *Puppetfile*:

```
mod 'vision_desktop',
    :git => 'https://github.com/vision-it/vision-desktop.git,
    :ref => 'production'
```

Include in a role/profile:

```puppet
contain ::vision_desktop
```

