#!/bin/bash

mkdir -p files/root
pushd files/root

popd

cat > files/etc/wsl.conf << EOF
[boot]
command = "/usr/bin/env -i /usr/bin/unshare --pid --mount-proc --fork --propagation private -- sh -c 'exec /sbin/init'"
EOF

chmod 644 files/etc/wsl.conf

mkdir -p files/etc/profile.d

cat > files/etc/profile.d/00-wsl-init.sh << EOF
#!/bin/bash

# Get PID of /sbin/procd(init)
# seems that we can't set /sbin/init as pid 1, as it quit immediately after started by above command in `wsl.conf`
sleep 1
pid="$(ps -u root -o pid,args | awk '$2 ~ /procd/ { print $1; exit }')"

# Run WSL service script
if [ "$pid" -ne 1 ]; then
  echo "Entering /sbin/procd(init) PID: $pid"
  exec /usr/bin/nsenter -p -m -t "${pid}" -- su - "$USER"
fi
EOF
