# TokenSage - AI Usage Tracker

Ứng dụng Windows để theo dõi token usage và chi phí khi sử dụng các AI IDE như Cursor, Windsurf, Kiro, Copilot...

## Tính năng

- 📊 Dashboard realtime theo dõi usage
- 💰 Tính chi phí tự động cho 350+ models
- 📈 Thống kê theo ngày/tổng
- 🔄 Auto-refresh mỗi 5 giây

## Cài đặt

1. Cài đặt [Node.js 18+](https://nodejs.org/)
2. Chạy `setup.bat`

## Sử dụng

1. Chạy `run.bat` để khởi động app
2. Dashboard sẽ tự mở tại http://localhost:4001
3. Cấu hình IDE của bạn để sử dụng proxy:

### Cursor
Settings > Models > Override OpenAI Base URL
```
http://localhost:4000/v1
```

### Windsurf
Settings > API Configuration > Base URL
```
http://localhost:4000/v1
```

### Kiro / Other IDEs
Set environment variable:
```
OPENAI_BASE_URL=http://localhost:4000/v1
```

## Dừng app

Chạy `stop.bat` hoặc nhấn `Ctrl+C` trong terminal

## API Endpoints

- `GET /stats` - Lấy thống kê usage
- `GET /history` - Lấy lịch sử requests
- `GET /health` - Health check

## Data

Dữ liệu được lưu trong thư mục `data/`:
- `usage_history.json` - Lịch sử usage
- `pricing.json` - Bảng giá models
- `models.json` - Danh sách models
