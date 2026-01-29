#  My Bus Map公車到站資訊

## 功能
UI設計和功能模仿App Store上知名公車app: [Bus+](https://apps.apple.com/tw/app/bus-%E5%85%AC%E8%BB%8A%E5%8B%95%E6%85%8B-ubike-%E8%87%BA%E9%90%B5%E6%9F%A5%E8%A9%A2/id967861325)

### 功能包括:
- 顯示目前位置附近的公車站牌
- 取得公車站牌的路線資訊、抵達時間
- 搜尋地點,取得該地點附近的公車站牌
- 收藏公車路線

### 技術/套件
- swiftUI
- MVVM架構
- Realm本地資料庫
- Firebase firestore同步資料
- 整合Google登入
- Google Map SDK地圖、Google Places SDK地點搜尋
- Carthage套件管理

### Screenshots

<img src="https://imgur.com/fbFPlGX.png"  width="150" height="300" />

## CI/CD（GitHub Actions + fastlane）

### 本機
- 安裝依賴：`bundle install`
- 跑測試：`bundle exec fastlane ios test`
- 建置（不上傳）：`bundle exec fastlane ios build`
- 送審 App Store（上傳並提交審查）：`bundle exec fastlane ios submit_app_store`
- TestFlight changelog：建立 `beta_changelog.txt`（內容為 changelog），`beta` / `beta_smoke` 會自動讀取上傳

### GitHub Actions
- Workflow：`.github/workflows/ios.yml`
- `test` job：每次 Push/PR 會跑 `fastlane ios ci`
- `beta` job：手動觸發 `workflow_dispatch` 後上傳 TestFlight（需要設定 Secrets）

### 需要的 Secrets（TestFlight）
- `FASTLANE_USER`：Apple ID（僅供 match 使用時需要）
- `MATCH_GIT_URL`、`MATCH_PASSWORD`：fastlane match 的憑證 repo 與密碼
- （選用）`MATCH_GIT_PRIVATE_KEY`：若 `MATCH_GIT_URL` 使用 SSH（`git@...`）時，提供可讀取該私有 repo 的 deploy key
- `ASC_KEY_ID`、`ASC_ISSUER_ID`、`ASC_KEY_CONTENT`：App Store Connect API Key（`ASC_KEY_CONTENT` 建議放 `.p8` 的 base64 單行字串）
  - 產生方式（macOS）：`base64 -i AuthKey_XXXXXX.p8 | tr -d '\\n'`

### fastlane match（憑證 / Provisioning Profiles）
1) 建立一個私有 git repo 來存放 match 產出（不要放在 app repo）
2) 設定環境變數（本機可用 `fastlane/.env`；範例見 `fastlane/.env.example`）：
   - `MATCH_GIT_URL`、`MATCH_PASSWORD`、（必要時）`FASTLANE_USER`
3) 初次建立/上傳（需要能登入 Apple Developer Portal）：
   - `bundle exec fastlane match appstore`
4) 只同步（不改 Portal；CI 常用）：
   - `bundle exec fastlane ios sync_signing type:appstore readonly:true`

### 需要的 Secrets（CI build 用 xcconfig）
- `API_CLIENT_ID`、`API_CLIENT_KEY`：用來在 CI 產生 `MyBusMapSwiftUI/Config.local.xcconfig`（PR 來源若拿不到 secrets 會用 `ci` 佔位值）

### 本機設定（不提交到 git）
- 建立 `MyBusMapSwiftUI/Config.local.xcconfig`（或沿用 repo root 的 `Config.local`），填入：
  - `API_CLIENT_ID = ...`
  - `API_CLIENT_KEY = ...`
