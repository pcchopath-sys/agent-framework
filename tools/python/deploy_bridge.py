import paramiko
import os
import sys
import json

class DeployBridge:
    def __init__(self, host, user, password):
        self.host = host
        self.user = user
        self.password = password
        self.ssh = None
        self.sftp = None

    def connect(self):
        try:
            self.ssh = paramiko.SSHClient()
            self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.ssh.connect(self.host, username=self.user, password=self.password, timeout=10)
            self.sftp = self.ssh.open_sftp()
            return True
        except Exception as e:
            print(f"Connection failed: {e}")
            return False

    def upload(self, local_path, remote_path):
        try:
            self.sftp.put(local_path, remote_path)
            return True
        except Exception as e:
            print(f"Upload failed {local_path} -> {remote_path}: {e}")
            return False

    def execute(self, cmd):
        try:
            stdin, stdout, stderr = self.ssh.exec_command(cmd)
            out = stdout.read().decode('utf-8').strip()
            err = stderr.read().decode('utf-8').strip()
            return {"ok": stdout.channel.exit_status == 0, "stdout": out, "stderr": err}
        except Exception as e:
            return {"ok": False, "error": str(e)}

    def close(self):
        if self.sftp: self.sftp.close()
        if self.ssh: self.ssh.close()

if __name__ == "__main__":
    # Simple CLI for quick tests
    if len(sys.argv) < 5:
        print("Usage: deploy_bridge.py <host> <user> <password> <cmd/upload_local_remote>")
        sys.exit(1)

    host, user, pwd, action = sys.argv[1:5]
    bridge = DeployBridge(host, user, pwd)
    if bridge.connect():
        if action.startswith("upload:"):
            _, l_path, r_path = action.split(":")
            success = bridge.upload(l_path, r_path)
            print(f"Upload success: {success}")
        else:
            res = bridge.execute(action)
            print(f"Result: {res}")
        bridge.close()
