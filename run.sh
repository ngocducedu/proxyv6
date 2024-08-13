#!/bin/bash

# Đường dẫn để lưu file boot_ipconfig.sh
output_file="/home/xpx/vivucloud/boot_ipconfig.sh"

# Đường dẫn để lưu file ipv6.txt
output_file_ipv6="/home/xpx/vivucloud/ipv6.txt"

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

# Tạo 500 địa chỉ IPv6 ngẫu nhiên và lưu vào file boot_ipconfig.sh và ipv6.txt
for i in $(seq 1 500); do
    random_suffix=$(generate_random_suffix)
    echo "ifconfig ens33 inet6 add $prefix$random_suffix/64" >> "$output_file"
    echo "$prefix$random_suffix" >> "$output_file_ipv6"
done


# Đặt quyền thực thi cho file boot_ipconfig.sh
chmod +x "$output_file"

echo "Script đã tạo thành công 500 địa chỉ IPv6 và lưu vào $output_file"
