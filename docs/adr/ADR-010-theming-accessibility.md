# ADR-010: Dynamic Theming and Accessibility

## Status
Accepted

## Context
O projeto precisava de suporte a temas dinâmicos (Android 12+), transições suaves entre temas, e temas de alto contraste para acessibilidade WCAG.

## Decision

### 1. Dynamic Colors (Android 12+)
Suportar cores dinâmicas baseadas no wallpaper do usuário.

```dart
static ThemeData fromDynamicColors({
  required Brightness brightness,
  ColorScheme? lightDynamic,
  ColorScheme? darkDynamic,
  bool highContrast = false,
});
```

### 2. High Contrast Theme
Implementar tema de alto contraste para acessibilidade.

```dart
static ThemeData get highContrastLight;
static ThemeData get highContrastDark;

static ColorScheme _buildHighContrastScheme(Brightness brightness) {
  // Cores com contraste máximo
  // Light: preto no branco
  // Dark: branco no preto
}
```

### 3. Animated Theme Transitions
Implementar transições suaves entre temas.

```dart
class AnimatedAppTheme extends StatelessWidget {
  final ThemeData theme;
  final Duration duration;
  final Curve curve;
  final Widget child;
}
```

### 4. Theme Extension
Estender ThemeData com propriedades customizadas.

```dart
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final bool isDark;
  final bool isHighContrast;
  final Color success;
  final Color warning;
  final Color info;
}
```

## Consequences

### Positive
- Experiência personalizada no Android 12+
- Acessibilidade WCAG 2.2 compliant
- Transições suaves melhoram UX
- Extensibilidade para cores customizadas

### Negative
- Complexidade adicional no código de tema
- Necessidade de testar múltiplas combinações

### Neutral
- Dynamic colors só funciona em Android 12+
- Fallback para tema padrão em outras plataformas

## Alternatives Considered

1. **Apenas light/dark** - Rejeitado por falta de acessibilidade
2. **Pacote dynamic_color** - Usado como base, mas abstração própria
3. **Sem transições** - Rejeitado por UX inferior
