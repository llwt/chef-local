name             'devtrw_lan'
maintainer       'Steven Nance <steven@devtrw.com>'
maintainer_email 'steven@devtrw.com'
license          'MIT'
description      'Installs/Configures devtrw_lan'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'pacman'

recipe 'devtrw_lan',                'Includes appropriate packages based on environment'
recipe 'devtrw_lan::packages_arch', 'Installs pacakages for arch linux'
