# Dev playground image: ${{ values.devName }}
# Self-service, auto-merged. Layered ON TOP of the golden ${{ values.goldenName }} image so
# a build only installs the delta (devs' SSH keys + extra packages).
# Build runs from packer/_build/ -> paths below are relative to that dir.
#
# source_url is the golden ${{ values.goldenName }} base published to the MinIO artifact store
# by the golden build (see packer/_build/publish-base.sh). The golden image must be
# built + published at least once before a dev build can run.
source_url      = "https://artifacts.platform.sthings.lab/packer/golden/${{ values.goldenName }}/${{ values.goldenName }}-amd64.img"
source_checksum = "none"

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
{%- endif %}
