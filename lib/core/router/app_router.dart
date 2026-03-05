import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/auth/profile_setup_screen.dart';
// Home
import '../../screens/home/home_screen.dart';
// Voice
import '../../screens/voice/voice_intent_screen.dart';
import '../../screens/voice/intent_confirmation_screen.dart';
// Workers
import '../../screens/workers/worker_list_screen.dart';
import '../../screens/workers/worker_profile_screen.dart';
// Service
import '../../screens/service/service_request_screen.dart';
import '../../screens/service/request_status_screen.dart';
import '../../screens/service/proposal_screen.dart';
import '../../screens/service/negotiation_screen.dart';
// Payment
import '../../screens/payment/payment_screen.dart';
import '../../screens/payment/final_payment_screen.dart';
// Tracking
import '../../screens/tracking/booking_live_screen.dart';
import '../../screens/tracking/service_in_progress_screen.dart';
import '../../screens/tracking/service_completed_screen.dart';
// Review
import '../../screens/review/review_screen.dart';
import '../../screens/review/booking_summary_screen.dart';
// Emergency
import '../../screens/emergency/sos_screen.dart';
import '../../screens/emergency/emergency_contacts_screen.dart';
// Profile / Utility
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/my_addresses_screen.dart';
import '../../screens/wallet/wallet_screen.dart';
import '../../screens/history/booking_history_screen.dart';

bool _isAuthed() =>
    Supabase.instance.client.auth.currentUser != null;

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final authed = _isAuthed();
    final path = state.uri.path;

    // Protected routes: redirect to login if not authenticated
    final protectedRoutes = [
      '/home', '/workers', '/voice', '/request', '/payment',
      '/profile', '/wallet', '/history', '/sos', '/emergency-contacts',
    ];
    final isProtected = protectedRoutes.any((r) => path.startsWith(r));

    if (!authed && isProtected) return '/login';
    // If logged in and trying to access auth screens, go home
    if (authed && (path == '/login' || path == '/splash')) return '/home';
    return null;
  },
  routes: [
    // ── Auth ──────────────────────────────────────────────────
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phone: phone);
      },
    ),
    GoRoute(path: '/setup', builder: (_, __) => const ProfileSetupScreen()),

    // ── Home ────────────────────────────────────────────────
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),

    // ── Voice / Intent ──────────────────────────────────────
    GoRoute(path: '/voice', builder: (_, __) => const VoiceIntentScreen()),
    GoRoute(
        path: '/confirm-intent',
        builder: (_, __) => const IntentConfirmationScreen()),

    // ── Workers ─────────────────────────────────────────────
    GoRoute(path: '/workers', builder: (_, __) => const WorkerListScreen()),
    GoRoute(
        path: '/worker/:id',
        builder: (_, state) =>
            WorkerProfileScreen(workerId: state.pathParameters['id']!)),

    // ── Service ─────────────────────────────────────────────
    GoRoute(
        path: '/request',
        builder: (_, state) {
          final worker = state.extra;
          return ServiceRequestScreen(worker: worker);
        }),
    GoRoute(
        path: '/request-status',
        builder: (_, state) => RequestStatusScreen(
              requestData: state.extra as Map<String, dynamic>?,
            )),
    GoRoute(path: '/proposal', builder: (_, __) => const ProposalScreen()),
    GoRoute(
        path: '/negotiation',
        builder: (_, __) => const NegotiationScreen()),

    // ── Payment ─────────────────────────────────────────────
    GoRoute(path: '/payment', builder: (_, __) => const PaymentScreen()),
    GoRoute(
        path: '/final-payment',
        builder: (_, __) => const FinalPaymentScreen()),

    // ── Tracking ────────────────────────────────────────────
    GoRoute(
        path: '/booking-live',
        builder: (_, __) => const BookingLiveScreen()),
    GoRoute(
        path: '/in-progress',
        builder: (_, __) => const ServiceInProgressScreen()),
    GoRoute(
        path: '/completed',
        builder: (_, __) => const ServiceCompletedScreen()),

    // ── Review ───────────────────────────────────────────────
    GoRoute(path: '/review', builder: (_, __) => const ReviewScreen()),
    GoRoute(
        path: '/booking-summary',
        builder: (_, __) => const BookingSummaryScreen()),

    // ── Emergency ───────────────────────────────────────────
    GoRoute(path: '/sos', builder: (_, __) => const SosScreen()),
    GoRoute(
        path: '/emergency-contacts',
        builder: (_, __) => const EmergencyContactsScreen()),

    // ── Profile / Utility ────────────────────────────────────
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/addresses', builder: (_, __) => const MyAddressesScreen()),
    GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
    GoRoute(path: '/history', builder: (_, __) => const BookingHistoryScreen()),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('404 – Page not found: ${state.uri}',
          style: const TextStyle(color: Colors.white)),
    ),
  ),
);
