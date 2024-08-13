#!/bin/bash

# Đường dẫn để lưu file boot_ipconfig.sh
output_file="/home/xpx/vivucloud/boot_ipconfig.sh"

# Đường dẫn để lưu file ipv6.txt
output_file_ipv6="/home/xpx/vivucloud/ipv6.txt"

# Đường dẫn để lưu file 3proxy.cfg
output_file_3proxycfg="/root/3proxy/p3proxy.cfg"

# Xóa file cũ nếu đã tồn tại
rm -f "$output_file"

# Lấy địa chỉ IPv6 của máy, chỉ lấy dòng đầu tiên
ipv6_address=$(ip -6 addr show ens33 | grep -m 1 -oP '(?<=inet6\s)[a-f0-9:]+(?=/64)')

# Kiểm tra xem địa chỉ IPv6 có được lấy thành công không
if [ -z "$ipv6_address" ]; then
    echo "Không thể lấy địa chỉ IPv6. Vui lòng kiểm tra kết nối mạng."
    exit 1
fi

# Lấy phần prefix của địa chỉ IPv6, chỉ lấy 4 nhóm đầu tiên
prefix=$(echo "$ipv6_address" | sed -E 's/^(([0-9a-fA-F]{1,4}:){4}).*$/\1/')

# Hàm tạo suffix ngẫu nhiên
generate_random_suffix() {
    printf "%04x:%04x:%04x:%04x" $((RANDOM%65536)) $((RANDOM%65536)) $((RANDOM%65536)) $((RANDOM%65536))
}

# Ghi các cấu hình cố định vào file 3proxy.cfg
cat <<EOT >> "$output_file_3proxycfg"
daemon
maxconn 3000
nserver 1.1.1.1
nserver [2606:4700:4700::1111]
nserver [2606:4700:4700::1001]
nserver [2001:4860:4860::8888]
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
stacksize 6291456
flush
auth none
EOT

# Tạo 500 địa chỉ IPv6 ngẫu nhiên và lưu vào file boot_ipconfig.sh và ipv6.txt
for i in $(seq 1 500); do
    random_suffix=$(generate_random_suffix)
    echo "ifconfig ens33 inet6 add $prefix$random_suffix/64" >> "$output_file"
    echo "$prefix$random_suffix" >> "$output_file_ipv6"

    # Tạo dòng cấu hình proxy và lưu vào 3proxy.cfg
    port=$((14000 + i))
    echo "proxy -6 -n -a -p$port -i192.168.1.151 -e$prefix$random_suffix" >> "$output_file_3proxycfg"
done


# Đặt quyền thực thi cho file boot_ipconfig.sh
chmod +x "$output_file"

echo "Script đã tạo thành công 500 địa chỉ IPv6 và lưu vào $output_file"
