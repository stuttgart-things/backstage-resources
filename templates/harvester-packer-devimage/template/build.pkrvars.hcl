# Dev playground image: ${{ values.devName }}
# Self-service, auto-merged. Layered ON TOP of the golden ${{ values.goldenName }} image so
# a build only installs the delta (devs' SSH keys + extra packages).
# Build runs from packer/_build/ -> paths below are relative to that dir.
#
# source_url is the golden ${{ values.goldenName }} base published to the MinIO artifact store
# by the golden build (see packer/_build/publish-base.sh). The golden image must be
# built + published at least once before a dev build can run.
#
# source_checksum pins that base: publish-base.sh writes a .sha256 next to the
# image and packer verifies against it, so a dev build cannot silently layer on a
# truncated or half-published golden. The file holds a bare hash with no filename,
# which packer's file: prefix accepts (verified: a wrong hash fails the build).
source_url      = "https://artifacts.platform.sthings.lab/packer/golden/${{ values.goldenName }}/${{ values.goldenName }}-amd64.img"
source_checksum = "file:https://artifacts.platform.sthings.lab/packer/golden/${{ values.goldenName }}/${{ values.goldenName }}-amd64.img.sha256"

image_name    = "${{ values.devName }}"
users_file    = "../dev/${{ values.devName }}/users.yaml"
packages_file = "../dev/${{ values.devName }}/packages.yaml"
{%- if 'rocky' in values.goldenName %}

# Rocky-specific overrides (the golden base still logs in as the 'rocky' user).
ssh_username = "rocky"
ssh_timeout  = "10m"
qemuargs = [
  ["-cdrom", "cidata.iso"],
  ["-machine", "type=q35,accel=kvm"],
  ["-cpu", "host"],
]
{%- elif 'leap' in values.goldenName %}

# openSUSE-specific override (the golden base still logs in as the 'opensuse' user).
ssh_username = "opensuse"
{%- endif %}
