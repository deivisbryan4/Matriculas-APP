import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: SizedBox(
          width: 600,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings, color: AppTheme.greyText),
                      SizedBox(width: 12),
                      Text('Configuración académica — Ing. de Sistemas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildInputField('Nota mínima de aprobación', system.notaMinima.toString()),
                  const SizedBox(height: 24),
                  _buildInputField('Máx. créditos — estudiante regular', system.maxCreditosRegular.toString()),
                  const SizedBox(height: 24),
                  _buildInputField('Máx. créditos — estudiante observado', system.maxCreditosObservado.toString()),
                  const SizedBox(height: 24),
                  _buildInputField('Máx. veces desaprobado (antes inhabilitación)', system.maxVecesDesaprobado.toString()),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.navyBlue),
                      child: const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.greyText, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
