# Auto Setup Scripts

Các script tự động cài đặt và cấu hình môi trường phát triển và công cụ pentest trên Linux.

## Cấu trúc thư mục

```
.
├── common.sh              # Script cài đặt các công cụ cơ bản
├── install_pentest_tools.sh  # Script cài đặt công cụ pentest
└── README.md             # File hướng dẫn này
```

## Tính năng

### common.sh
- Cài đặt và cấu hình ZSH với Oh-My-Zsh
- Cài đặt các ngôn ngữ lập trình:
  - Go
  - Rust
  - Python
  - Node.js
- Cài đặt các thư viện:
  - Yarn
  - pip
- Tự động cấu hình PATH trong .zshrc
- Hỗ trợ nhiều hệ điều hành Linux

### install_pentest_tools.sh
- Kế thừa tất cả tính năng từ common.sh
- Cài đặt thêm các công cụ pentest:
  - Công cụ hệ thống:
    - nmap: Quét mạng và bảo mật
    - gobuster: Quét thư mục web
    - dirb: Quét thư mục web
    - nikto: Quét lỗ hổng web
    - hydra: Cracking mật khẩu
    - sqlmap: Khai thác SQL injection
    - metasploit-framework: Framework khai thác lỗ hổng
  - Công cụ Go:
    - fff: Fast File Finder
    - waybackurls: Tìm URL từ Wayback Machine
    - assetfinder: Tìm subdomain
    - gf: Pattern matching
    - httprobe: Kiểm tra HTTP/HTTPS endpoints
    - meg: Parallel HTTP requests
    - qsreplace: Thay thế query string
    - unfurl: Phân tích URL
    - anew: Thêm dòng mới vào file
    - gron: Làm việc với JSON
  - Công cụ Python (trong môi trường ảo):
    - subfinder: Tìm subdomain
    - amass: Quét bảo mật
    - dnsrecon: Phân tích DNS
    - massdns: Quét DNS nhanh
    - dnsvalidator: Kiểm tra DNS
    - dnsgen: Tạo DNS
    - altdns: Thay thế DNS
    - masscan: Quét port nhanh
    - ffuf: Fuzzing web
    - nuclei: Quét lỗ hổng
    - httpx: HTTP toolkit
    - subjack: Subdomain takeover
    - waybackpy: Wayback Machine API
    - dalfox: XSS scanner
    - gf-patterns: Pattern matching
    - hakrawler: Crawler

## Yêu cầu hệ thống

- Hệ điều hành Linux được hỗ trợ:
  - Ubuntu
  - Debian
  - Parrot OS
  - Kali Linux
  - Linux Mint
  - Elementary OS
- Quyền sudo để cài đặt packages
- Kết nối internet để tải packages

## Cách sử dụng

1. Tải các script:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Cấp quyền thực thi:
```bash
chmod +x common.sh install_pentest_tools.sh
```

3. Chạy script:

- Để cài đặt các công cụ cơ bản:
```bash
sudo ./common.sh
```

- Để cài đặt công cụ pentest (bao gồm cả công cụ cơ bản):
```bash
sudo ./install_pentest_tools.sh
```

4. Sau khi cài đặt:
```bash
# Chuyển sang shell zsh
zsh

# Các công cụ Python sẽ tự động được kích hoạt trong môi trường ảo
# Kiểm tra cài đặt:
which fff  # Công cụ Go
which subfinder  # Công cụ Python
```

## Lưu ý quan trọng

1. Script sẽ tự động:
   - Phát hiện hệ điều hành
   - Cài đặt các công cụ phù hợp
   - Cấu hình PATH trong .zshrc
   - Tạo môi trường ảo Python cho các công cụ pentest
   - Áp dụng thay đổi vào shell hiện tại

2. Nếu một công cụ đã được cài đặt:
   - Script sẽ hiển thị thông báo màu xanh
   - Không cài đặt lại công cụ đó

3. Nếu gặp lỗi:
   - Kiểm tra quyền sudo
   - Kiểm tra kết nối internet
   - Kiểm tra log để biết chi tiết lỗi
   - Đảm bảo đang sử dụng shell zsh

## Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng:
1. Fork repository
2. Tạo branch mới
3. Commit thay đổi
4. Push lên branch
5. Tạo Pull Request

## Giấy phép

MIT License

```bash
sudo apt update && sudo apt install zsh
chsh -s $(which zsh)
```

- Install Oh-My-Zsh

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
