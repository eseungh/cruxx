CRUXX 프로젝트 핵심 프로토콜 명세

(SwiftPM + Xcode 프로젝트 공통, 최신 기준)

---

**📌 적용 및 운영 원칙**

- 이 문서의 모든 프로토콜 정의는CRUXX 프로젝트의 Xcode 프로젝트 환경에서서비스, 매니저, 뷰모델 등 핵심 구현체의 “공통 인터페이스”로 반드시 준수해야 함
- 구현체(클래스/구조체)는 STRUCTURE.md 기준 폴더에 위치
- 외부 타입(UIKit, AVFoundation 등) 의존이 필요한 경우import를 반드시 파일 상단에 명시(예: UIImage, CMSampleBuffer, CVPixelBuffer 등)
- 프로토콜 정의는 보통 Sources/CRUXX/Core/Protocols/(또는 기능별/모듈별) 폴더에 파일로도 분리 관리함

---

**예시 import 구문 (파일 상단용)**

import Foundation import UIKit // UIImage 필요시 import AVFoundation // CMSampleBuffer 등 필요시

---

**프로토콜 명세**

**1. 세션 관리**

protocol SessionManagerProtocol { func fetchSessions() -> [ClimbingSessionModel] // 모든 세션 목록 조회 func saveSession(_ session: ClimbingSessionModel) // 세션 저장 func deleteSession(_ session: ClimbingSessionModel) // 세션 삭제 func updateSession(_ session: ClimbingSessionModel) // 세션 수정 func fetchSession(by id: UUID) -> ClimbingSessionModel? // 단일 세션 조회 }

---

**2. 영상 녹화/카메라 제어**

protocol CameraServiceProtocol { func startCamera(completion: @escaping (Bool) -> Void) // 카메라 시작 func stopCamera() // 카메라 종료 func capturePhoto(completion: @escaping (Data?) -> Void) // 사진 데이터 캡처 func startRecording(completion: @escaping (Bool) -> Void) // 영상 녹화 시작 func stopRecording(completion: @Sendable @escaping (URL?) -> Void) // 영상 녹화 종료, 파일 URL 반환 }

---

**3. 영상 저장/쓰기**

protocol VideoWriterProtocol { func startWriting() // 영상 기록 시작 func appendFrame(_ sampleBuffer: CMSampleBuffer) // 프레임 추가 func finishWriting(completion: @escaping (URL?) -> Void) // 기록 완료, 파일 URL 반환 }

---

**4. AI 동작/포즈 분석**

protocol PoseAnalyzerProtocol { func analyze(videoURL: URL, completion: @escaping (PoseAnalysisResult) -> Void) // 영상 분석 func analyze(imageData: Data) -> PoseTimestampData? // 이미지(프레임) 분석 }

---

**5. 온디바이스 AI 모델**

protocol OnDevicePoseModelProtocol { func predictPoses(from pixelBuffer: CVPixelBuffer) -> [Pose] // 이미지 버퍼에서 스켈레톤 추론 }

---

**6. 프리미엄 AI 분석/클러스터링**

protocol PremiumAnalyzerProtocol { func analyzeAdvanced(session: ClimbingSessionModel, completion: @escaping (AdvancedAnalysisResult) -> Void) }

protocol ClusteringModelProtocol { func clusterProblems(from problems: [ClimbingProblem]) -> [[ClimbingProblem]] }

---

**7. 데이터 소스/저장소**

protocol LocalDataSourceProtocol { func save(_ session: ClimbingSessionModel) func loadAllSessions() -> [ClimbingSessionModel] func delete(_ session: ClimbingSessionModel) }

protocol RemoteDataSourceProtocol { func upload(_ session: ClimbingSessionModel, completion: @escaping (Bool) -> Void) func fetchSessions(completion: @escaping ([ClimbingSessionModel]) -> Void) }

protocol SessionRepositoryProtocol { func getSessions() -> [ClimbingSessionModel] func addSession(_ session: ClimbingSessionModel) func removeSession(_ session: ClimbingSessionModel) func updateSession(_ session: ClimbingSessionModel) }

---

**8. 네트워킹**

protocol APIClientProtocol { func request<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void) }

---

**9. ViewModel/DI(의존성 주입)**

protocol Injectable { associatedtype Dependency init(container: Dependency) }

---

**🔖 추가 참고**

- 각 프로토콜에 등장하는 타입(ClimbingSessionModel, Pose, PoseAnalysisResult 등)은반드시 Sources/CRUXX/Core/Model/ 이하에 정의
- 필요한 프로토콜은 기능별로 분리하거나, Core/Protocols/Protocols.swift에 통합 가능
- 구현 클래스/구조체는 STRUCTURE.md 기준 폴더에 생성,프로토콜 인터페이스를 반드시 구현해야 함

---

이 문서는 CRUXX 앱(프로젝트)의 모든 서비스/매니저/뷰모델 구현의 “인터페이스 기준”입니다.

Xcode 프로젝트에서 공통 적용되며,

AI/팀원/외주/자동화 등 어떤 상황에서도 항상 이 규격을 최우선으로 따릅니다.
