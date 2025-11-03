# Class Whisperer (RTDB + Bloc + M3)

- Admin creates **Courses** (QR/code). Others join via **QR** or **private code**.
- Inside a course:
  - **General**: ask anonymously, upvote, peer answers (no delete).
  - **Lectures**: instructor starts sessions; ask/upvote/answer per session.
- Dashboard shows your **courses** and **your questions**.
- Drawer: Courses, Questions, Ask to Professor, Sign out.
- Backend: Firebase **Auth** + **Realtime Database**.

## RTDB Structure
```
users/{uid}: { realName, anonName, bannerId, role }
courses/{courseId}: { title, code, createdBy, createdAt }
courseMembers/{courseId}/{uid}: { role, joinedAt }
courseGeneralQuestions/{courseId}/{questionId}: { text, upvotes, authorUid, timestamp, votes/{uid}, answers/{answerId} }
lectures/{courseId}/{lectureId}: { title, active, createdAt }
lectureQuestions/{courseId}/{lectureId}/{questionId}: { text, upvotes, authorUid, timestamp, votes/{uid}, answers/{answerId} }
userQuestions/{uid}/{questionRefId}: { path, courseId, lectureId? }
```

## Setup
1) Add Firebase configs (Android/iOS/Web) and/or run `flutterfire configure`.
2) `flutter pub get`
3) `flutter run`
