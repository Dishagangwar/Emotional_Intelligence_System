import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/backend.dart';
import '../../services/check_in_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

/// Opens the account sheet. Returns `true` if the user is signed in when the
/// sheet closes.
Future<bool> showAccountSheet(BuildContext context, {String? reason}) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => _AccountSheet(reason: reason),
  );
  return AuthService.isSignedIn;
}

class _AccountSheet extends StatelessWidget {
  final String? reason;

  const _AccountSheet({this.reason});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          EmoSpace.gutter,
          0,
          EmoSpace.gutter,
          EmoSpace.xl,
        ),
        child: !Backend.isAvailable
            ? const _OfflineInfo()
            : StreamBuilder(
                stream: AuthService.changes,
                builder: (context, _) => AuthService.isSignedIn
                    ? const _SignedInView()
                    : _SignInForm(reason: reason),
              ),
      ),
    );
  }
}

class _OfflineInfo extends StatelessWidget {
  const _OfflineInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cloud sync is off', style: context.text.headlineSmall),
        const SizedBox(height: EmoSpace.xs),
        Text(Backend.offlineReason, style: context.text.bodyMedium),
      ],
    );
  }
}

class _SignedInView extends StatefulWidget {
  const _SignedInView();

  @override
  State<_SignedInView> createState() => _SignedInViewState();
}

class _SignedInViewState extends State<_SignedInView> {
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = CheckInRepository.describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all check-ins?'),
        content: const Text(
          'This permanently removes your entire history from the cloud. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ctx.emo.danger),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(CheckInRepository.deleteAll);
      if (mounted && _error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your history was deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final email = AuthService.currentUser?.email ?? 'Signed in';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: p.brand.withValues(alpha: 0.1),
              child: Text(
                email.isNotEmpty ? email[0].toUpperCase() : '?',
                style: context.text.titleMedium?.copyWith(color: p.brand),
              ),
            ),
            const SizedBox(width: EmoSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your account', style: context.text.headlineSmall),
                  Text(
                    email,
                    style: context.text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: EmoSpace.md),
        Text(
          'Saved check-ins sync to your account and appear under Insights → My history. '
          'Only you can see them.',
          style: context.text.bodySmall,
        ),
        if (_error != null) ...[
          const SizedBox(height: EmoSpace.sm),
          Text(
            _error!,
            style: context.text.bodySmall?.copyWith(color: p.danger),
          ),
        ],
        const SizedBox(height: EmoSpace.lg),
        EmoButton.secondary(
          label: 'Sign out',
          icon: Icons.logout_rounded,
          expand: true,
          onPressed: _busy ? null : () => _run(AuthService.signOut),
        ),
        const SizedBox(height: EmoSpace.xs),
        Center(
          child: TextButton.icon(
            onPressed: _busy ? null : _confirmDeleteAll,
            style: TextButton.styleFrom(foregroundColor: p.danger),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Delete all my check-ins'),
          ),
        ),
      ],
    );
  }
}

class _SignInForm extends StatefulWidget {
  final String? reason;

  const _SignInForm({this.reason});

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _createAccount = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      if (_createAccount) {
        final outcome = await AuthService.signUp(
          email: _email.text,
          password: _password.text,
        );
        if (outcome == SignUpOutcome.confirmEmail && mounted) {
          setState(() {
            _notice =
                'Check ${_email.text.trim()} for a confirmation link, then sign in here.';
            _createAccount = false;
          });
        }
      } else {
        await AuthService.signIn(email: _email.text, password: _password.text);
      }
      if (AuthService.isSignedIn && mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _decoration(
    BuildContext context,
    String label, {
    Widget? suffix,
  }) {
    final p = context.emo;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(EmoRadius.md),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: p.surface,
      suffixIcon: suffix,
      border: border(p.border),
      enabledBorder: border(p.border),
      focusedBorder: border(p.brand, 1.5),
      errorBorder: border(p.danger),
      focusedErrorBorder: border(p.danger, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _createAccount ? 'Create your account' : 'Sign in',
              style: context.text.headlineSmall,
            ),
            const SizedBox(height: EmoSpace.xxs),
            Text(
              widget.reason ?? 'Save check-ins and see your personal history across devices.',
              style: context.text.bodySmall,
            ),
            const SizedBox(height: EmoSpace.lg),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: _decoration(context, 'Email'),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Enter your email';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: EmoSpace.sm),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: [
                _createAccount
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: _decoration(
                context,
                'Password',
                suffix: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                if ((v ?? '').isEmpty) return 'Enter your password';
                if (_createAccount && v!.length < 8) {
                  return 'Use at least 8 characters';
                }
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: EmoSpace.sm),
              Text(
                _error!,
                style: context.text.bodySmall?.copyWith(color: p.danger),
              ),
            ],
            if (_notice != null) ...[
              const SizedBox(height: EmoSpace.sm),
              InlineNotice(
                icon: Icons.mark_email_unread_outlined,
                color: p.brand,
                title: 'Confirm your email',
                message: _notice!,
              ),
            ],
            const SizedBox(height: EmoSpace.lg),
            EmoButton(
              label: _busy
                  ? 'Please wait…'
                  : (_createAccount ? 'Create account' : 'Sign in'),
              expand: true,
              onPressed: _busy ? null : _submit,
            ),
            const SizedBox(height: EmoSpace.xs),
            Center(
              child: EmoButton.ghost(
                label: _createAccount
                    ? 'I already have an account'
                    : 'New here? Create an account',
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _createAccount = !_createAccount;
                        _error = null;
                      }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
