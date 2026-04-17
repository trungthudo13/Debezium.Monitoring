# Debezium Monitoring

Source này dùng để cung cấp giải pháp monitor Debezium cluster, tập trung vào việc kiểm tra tình trạng toàn bộ connector `source` và `sink` thông qua Debezium Connect REST API.

Hiện tại repository cung cấp:

- Healthcheck script để kiểm tra trạng thái connector và task.
- Cơ chế xuất lỗi ra `stderr` và `system log` khi phát hiện bất thường.

## Cấu hình

Tạo file `.env` và khai báo tối thiểu:

```bash
DEBEZIUM_URL=http://your-debezium-connect:8083
CURL_INSECURE=false
CONNECTOR_RESTART_DELAY=10
```

Môi trường chạy cần có `curl` và một trong hai công cụ: `jq` hoặc `python3`.

Nếu endpoint dùng certificate nội bộ hoặc self-signed, có thể bật:

```bash
CURL_INSECURE=true
```

Nếu cần chờ connector lên lại sau khi restart, có thể chỉnh:

```bash
CONNECTOR_RESTART_DELAY=10
```

## Cách dùng healthcheck

Chạy trực tiếp trong shell:

```bash
source .env && source scripts/.healthzc
```

Nếu cần chạy qua `zsh -lc` mà không muốn terminal tự đóng sau khi xong lệnh:

```bash
zsh -lc 'source .env && source scripts/.healthzc; exec zsh -l'
```

Script sẽ:

- Gọi Debezium Connect REST API để lấy danh sách connector.
- Kiểm tra trạng thái của toàn bộ Debezium `source` và `sink`.
- In chi tiết lỗi và `trace` ra log hệ thống để tiện theo dõi.
- Nếu `connectors/<connector-name>/status` có trạng thái `FAILED` ở connector hoặc task, script sẽ tự `stop` rồi `resume` đúng connector đó.
- Sau khi restart connector, script sẽ chờ connector lên lại, kiểm tra status một lần nữa và ghi log kết quả sau restart.
- Trả về mã lỗi khác `0` nếu connector vẫn lỗi sau khi restart hoặc có lỗi ở trạng thái khác ngoài `FAILED`.

## Ghi chú

Phần tài liệu và các tiện ích monitor khác sẽ được bổ sung sau.
