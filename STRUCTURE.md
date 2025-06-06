# CRUXX 프로젝트 파일/폴더 구조 및 역할 (SwiftPM + Xcode 기준)

“본 프로젝트는 SwiftPM(Package.swift) + Xcode 프로젝트(cruxx.xcodeproj) 구조를 항상 병행합니다.”

| 경로 | 역할(한글 설명) |
| --- | --- |
| Package.swift | SwiftPM 메타파일(빌드, 의존성, 테스트 자동화) |
| cruxx.xcodeproj/ | Xcode 프로젝트 파일(앱 실행/배포/스토어 제출 필수) |
| Sources/CRUXX/App/ClerApp.swift | 앱 엔트리포인트, DIContainer 연결 |
| Sources/CRUXX/App/AppRouter.swift | 메인 네비게이션(TabView), 화면 라우팅 |
| Sources/CRUXX/App/DIContainer.swift | 전역 의존성 관리, 서비스/뷰모델 주입 |
| Sources/CRUXX/Core/Model/ClimbingSession.swift | 등반 세션(1회 기록) 모델 정의 |
| Sources/CRUXX/Core/Model/PoseTimestampData.swift | 프레임별 포즈(스켈레톤) 데이터 구조 |
| Sources/CRUXX/Core/Model/MovementType.swift | 동작 분류/타입 정의(이동, 정지, 점프 등) |
| Sources/CRUXX/Core/Service/PoseAnalyzer.swift | AI 동작/포즈 분석, 스켈레톤 데이터 해석 로직 |
| Sources/CRUXX/Core/Service/SessionManager.swift | 세션 저장/불러오기, 세션 리스트 관리 |
| Sources/CRUXX/Core/Service/CameraService.swift | 카메라 제어, 촬영 관련 로직 |
| Sources/CRUXX/Core/Service/VideoWriter.swift | 영상 파일 저장/녹화 관리 |
| Sources/CRUXX/Core/Utils/Constants.swift | 상수, 전역 파라미터 등 유틸 |
| Sources/CRUXX/Features/Main/MainView.swift | 메인 대시보드(홈) UI |
| Sources/CRUXX/Features/Main/MainViewModel.swift | 메인 대시보드 데이터/로직 |
| Sources/CRUXX/Features/Recording/RecordingView.swift | 영상 녹화/카메라 프리뷰/포즈 오버레이 UI |
| Sources/CRUXX/Features/Recording/RecordingViewModel.swift | 녹화 화면 상태 및 이벤트 처리 |
| Sources/CRUXX/Features/Session/SessionListView.swift | 세션 리스트(과거 기록 목록) UI |
| Sources/CRUXX/Features/Session/SessionListViewModel.swift | 세션 리스트 데이터/상태 관리 |
| Sources/CRUXX/Features/Session/SessionDetailView.swift | 세션 상세 분석/시각화 UI |
| Sources/CRUXX/Features/Session/SessionDetailViewModel.swift | 세션 상세 분석 데이터/상태 관리 |
| Sources/CRUXX/Features/Settings/SettingsView.swift | 환경설정(설정 화면) UI |
| Sources/CRUXX/Features/Settings/SettingsViewModel.swift | 환경설정 데이터/로직 |
| Sources/CRUXX/Shared/Components/PoseOverlayView.swift | 영상 위에 포즈(스켈레톤) 오버레이 뷰 |
| Sources/CRUXX/Shared/Components/VideoPlayerView.swift | 영상 재생 공통 뷰 |
| Sources/CRUXX/Shared/Components/PrimaryButton.swift | 앱 전반에서 쓰는 주요 버튼 |
| Sources/CRUXX/Shared/Extensions/Date+Format.swift | 날짜 관련 Swift 확장 |
| Sources/CRUXX/Data/Persistence/LocalDataSource.swift | 로컬 데이터(파일/DB) 저장/불러오기 |
| Sources/CRUXX/Data/Persistence/RemoteDataSource.swift | 서버 API 등 원격 데이터 소스 (확장용) |
| Sources/CRUXX/Data/Repository/SessionRepository.swift | 세션 데이터 통합 관리(도메인↔저장소 매핑) |
| Sources/CRUXX/Data/DTO/SessionDTO.swift | 세션 데이터 전송 객체 |
| Sources/CRUXX/Data/DTO/AnalysisDTO.swift | 분석 데이터 전송 객체 |
| Sources/CRUXX/Infrastructure/Networking/APIClient.swift | 네트워크 통신/REST API 클라이언트 |
| Sources/CRUXX/Infrastructure/AI/OnDevicePoseModel.swift | 온디바이스 포즈 추론 모델 래퍼 |
| Sources/CRUXX/Infrastructure/AI/PremiumAnalyzer.swift | 프리미엄 고급 분석(AI) 엔진 |
| Sources/CRUXX/Infrastructure/AI/ClusteringModel.swift | 코스/문제 클러스터링 AI 모델 |
| Sources/CRUXX/Infrastructure/ThirdParty/(필요 시 추가) | 외부 SDK/라이브러리 래퍼 |
| Assets.xcassets/ | 앱 아이콘, 색상, 이미지 등 리소스 폴더 |
| Preview/MockData.swift | 프리뷰용 목업/더미 데이터 |
| Tests/CRUXXTests/UnitTests/SessionManagerTests.swift | 세션 매니저 관련 유닛 테스트 |
| Tests/CRUXXTests/UITests/MainViewUITests.swift | 메인화면 UI 테스트 |
| [README.md] | 프로젝트 소개, 빌드/실행 방법 등 문서 |
| [AGENTS.md] | 프로젝트 운영/협업 최상위 가이드 |
| [STRUCTURE.md] | 폴더/파일 구조 및 위치 기준 |
| [PROTOCOLS.md] | 서비스/매니저/뷰모델 프로토콜 기준 |
