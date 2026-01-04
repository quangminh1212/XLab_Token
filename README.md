# TokenSage - AI Usage Tracker

Ứng dụng Windows để theo dõi token usage và chi phí khi sử dụng các AI IDE như Cursor, Windsurf, Kiro, Copilot...

## Tính năng

- 📊 Dashboard realtime theo dõi usage
- 💰 Tính chi phí tự động cho 350+ models
- 📈 Thống kê theo ngày/tổng
- 📋 Live Log panel
- 🔄 Auto-refresh mỗi 5 giây
- 🌐 Intercept tất cả AI requests tự động (mitmproxy)

## Cài đặt

1. Cài đặt [Node.js 18+](https://nodejs.org/)
2. Cài đặt mitmproxy: `pip install mitmproxy`
3. Chạy `setup.bat`

## Sử dụng

### Chế độ 1: Auto Track (Khuyến nghị)
Track tất cả AI requests tự động:
```
start-tracking.bat
```
- Tự động bật Windows system proxy
- Intercept tất cả HTTPS traffic đến AI APIs
- Tự động tắt proxy khi dừng

**Lần đầu sử dụng**: Cài certificate mitmproxy
1. Chạy `start-tracking.bat`
2. Mở browser, vào http://mitm.it
3. Tải và cài certificate Windows

### Chế độ 2: Manual Proxy
Chỉ track apps được cấu hình:
```
run.bat
```
Cấu hình IDE:
- Cursor: Settings > Models > Override OpenAI Base URL = `http://localhost:4000/v1`
- Windsurf: Settings > API Configuration > Base URL = `http://localhost:4000/v1`

## Dừng tracking

```
stop-tracking.bat
```
hoặc nhấn `Ctrl+C`

## Dashboard

- URL: http://localhost:4001
- Hiển thị: Today stats, All time stats, Recent Activity, Live Log

## API Endpoints

- `GET /stats` - Lấy thống kê usage
- `GET /history` - Lấy lịch sử requests
- `POST /ingest` - Nhận data từ mitmproxy
- `GET /health` - Health check

## Data

Dữ liệu được lưu trong thư mục `data/`:
- `usage_history.json` - Lịch sử usage
- `pricing.json` - Bảng giá models
