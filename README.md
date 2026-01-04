# TokenSage - AI Usage Tracker

Ứng dụng Windows để theo dõi token usage và chi phí khi sử dụng các AI IDE như Cursor, Windsurf, Kiro, Copilot...

## Tính năng

- 📊 Dashboard realtime theo dõi usage
- 💰 Tính chi phí tự động cho 350+ models  
- 📋 Live Log panel
- 🌐 **Transparent proxy** - intercept TẤT CẢ traffic tự động (WinDivert)

## Cài đặt

1. Cài đặt [Node.js 18+](https://nodejs.org/)
2. Cài đặt mitmproxy: `pip install mitmproxy`
3. Chạy `setup.bat`

## Sử dụng

```
run.bat
```

**Chạy với quyền Administrator** để transparent proxy hoạt động.

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
