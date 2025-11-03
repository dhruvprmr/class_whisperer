import 'package:class_whisperer/presentation/screens/settings/settings.dart';
import 'package:flutter/material.dart';

// === AUTH ===
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';

// === HOME ===
import '../presentation/screens/home/dashboard_screen.dart';

// === COURSES ===
import '../presentation/screens/course/courses_screen.dart';
import '../presentation/screens/course/course_home_screen.dart';

// === PROFESSOR ===
import '../presentation/screens/professor/create_lecture_screen.dart';
import '../presentation/screens/professor/lecture_qna_screen.dart';

// === ADMIN ===
import '../presentation/screens/admin/admin_create_course_screen.dart';

// === MISC ===
import '../presentation/screens/misc/ask_professor_screen.dart';
import '../presentation/screens/misc/my_questions_screen.dart';
import '../presentation/screens/misc/about_screen.dart';
import '../presentation/screens/misc/help_screen.dart';

// === SETTINGS ===

class AppRoutes {
  // AUTH
  static const login = '/';
  static const register = '/register';

  // CORE
  static const dashboard = '/dashboard';

  // COURSES
  static const courses = '/courses';
  static const courseHome = '/course';

  // PROFESSOR
  static const createLecture = '/create-lecture';
  static const lectureQnA = '/lecture-qna';

  // ADMIN
  static const adminCreateCourse = '/admin-create-course';

  // MISC
  static const askProfessor = '/ask-professor';
  static const myQuestions = '/my-questions';

  // NEW ROUTES
  static const settings = '/settings';
  static const about = '/about';
  static const help = '/help';

  // === ROUTE MAP ===
  static Map<String, WidgetBuilder> map = {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    dashboard: (_) => const DashboardScreen(),
    courses: (_) => const CoursesScreen(),
    courseHome: (_) => const CourseHomeScreen(),
    createLecture: (_) => const CreateLectureScreen(),
    lectureQnA: (_) => const LectureQnAScreen(),
    adminCreateCourse: (_) => const AdminCreateCourseScreen(),
    askProfessor: (_) => const AskProfessorScreen(),
    myQuestions: (_) => const MyQuestionsScreen(),

    // NEW
    settings: (_) => const SettingsScreen(),
    about: (_) => const AboutScreen(),
    help: (_) => const HelpScreen(),
  };
}
