// lib/features/auth/screens/register_screen.dart

import 'package:cashflyseguros/responsive_layout.dart';
import 'package:cashflyseguros/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth_service.dart';


class RegisterScreen extends StatefulWidget {
  final String? referralCode;
  final String? prefillName;
  const RegisterScreen({super.key, this.referralCode, this.prefillName});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late final TextEditingController _refCtrl;
  final _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _refCtrl = TextEditingController(text: widget.referralCode ?? '');
    if (widget.prefillName != null) _nameCtrl.text = Uri.decodeComponent(widget.prefillName!);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; _success = null; });

    try {
      await _authService.signUp(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        name: _nameCtrl.text,
        referralCode: _refCtrl.text.trim().isEmpty ? null : _refCtrl.text.trim(),
      );
      setState(() => _success =
      'Conta criada! Verifique seu email para confirmar o cadastro.');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 420 : double.infinity),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                if (_success != null) ...[
                  _buildSuccess(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Ir para Login'),
                  ),
                ] else ...[
                  _buildForm(),
                  const SizedBox(height: 16),
                  if (_error != null) _buildError(),
                  const SizedBox(height: 8),
                  _buildSubmitButton(),
                  const SizedBox(height: 32),
                  _buildLoginLink(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text('Criar Conta', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 6),
        Text(
          'Ganhe cashback nos seus seguros',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.cashback),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.textHint, size: 20),
            ),
            validator: (v) => v != null && v.trim().length >= 2 ? null : 'Informe seu nome',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textHint, size: 20),
            ),
            validator: (v) => v != null && v.contains('@') ? null : 'Email inválido',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textHint, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.textHint, size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _refCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Código de indicação (opcional)',
              prefixIcon: const Icon(Icons.card_giftcard_outlined, color: AppTheme.cashback, size: 20),
              helperText: widget.referralCode != null ? '✓ Código aplicado automaticamente' : null,
              helperStyle: const TextStyle(color: AppTheme.cashback, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cashback.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cashback.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppTheme.cashback, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(_success!, style: const TextStyle(color: AppTheme.cashback, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        child: _loading
            ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Criar conta'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Já tem conta?', style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: () => context.push('/login'),
          child: const Text('Entrar', style: TextStyle(color: AppTheme.primary)),
        ),
      ],
    );
  }
}