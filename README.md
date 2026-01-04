# TokenSage - AI Usage Tracker

Ứng dụng Windows để theo dõi token usage và chi phí khi sử dụng các AI IDE như Cursor, Windsurf, Kiro, Copilot...

## Tính năng

- 📊 Dashboard realtime theo dõi usage
- 💰 Tính chi phí tự động cho 350+ models  
- 📋 Live Log panel
- 🌐 All Captured Traffic panel

## Cài đặt

1. Cài đặt [Node.js 18+](https://nodejs.org/)
2. Cài đặt mitmproxy: `pip install mitmproxy`
3. Chạy `setup.bat`

## Sử dụng

### Cách 1: Safe Proxy Mode (Khuyến nghị)
```
run.bat
```
- Không gây mất mạng
- Cần cấu hình proxy trong Windows hoặc app:
  - Settings > Network > Proxy > Manual: `127.0.0.1:8080`
  - Hoặc: `set HTTPS_PROXY=http://127.0.0.1:8080`

### Cách 2: Transparent Mode (Rủi ro)
```
run_transparent.bat
```
- Tự động bắt tất cả traffic (cần Admin)
- ⚠️ Có thể gây mất mạng!

**Lần đầu** - cài certificate:
1. Chạy `run.bat` 
2. Mở browser: http://mitm.it
3. Tải và cài certificate Windows

## Dừng

```
stop.bat
```

## Dashboard

http://localhost:4001
