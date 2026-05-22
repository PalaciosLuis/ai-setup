# ai-setup — Asistente de desarrollo con OpenCode + Gentle AI

Configuración estándar del equipo para desarrollar con IA estructurada. Esto no es "un chat que escribe código" — es un asistente que guía el desarrollo con especificaciones, diseño, documentación y verificación.

## ¿Qué resuelve?

| Problema | Cómo lo resolvemos |
|----------|-------------------|
| No hay tests | Cada feature arranca con escenarios escritos (specs), listos para traducir a tests |
| Documentación pobre | Se genera automáticamente como parte del workflow, no como tarea separada |
| Code reviews inconsistentes | Se revisa spec + diseño primero, código después |
| Seguridad sin control | Permisos configurables, datos locales, modelos gratis |
| Cada uno usa lo que quiere | Soporta VS Code, Cursor, Antigravity, y terminal |

## Instalación

### Requisito para Windows

Los usuarios de Windows necesitan **Git Bash** (incluido con Git for Windows). Descargalo de https://git-scm.com si no lo tenés. El `setup.bat` lo detecta automáticamente y ejecuta `setup.sh`.

Si no querés instalar Git Bash, el `setup.bat` usa PowerShell como fallback.

---

### Perfil A: Uso VS Code (no querés terminal)

**1.** Ejecutá el script de instalación:

**Linux / macOS:**
```bash
cd ruta/a/este/repo
chmod +x setup.sh
./setup.sh
```

**Windows (recomendado):**
```batch
Hacé doble click en setup.bat
```
El script detecta Git Bash y ejecuta todo automáticamente.

**3.** Abrí VS Code, presioná `Ctrl+Shift+P`, buscá `OpenCode: Start Session`.

**4.** En el chat que aparece abajo, escribí:

```
/sdd-new "describí lo que necesitas hacer"
```

Ejemplos: `/sdd-new "agregar endpoint GET /api/products"`, `/sdd-new "validar email en el formulario de registro"`.

---

### Perfil B: Uso Cursor

**1.** Ejecutá el script de instalación:

**Linux / macOS:**
```bash
cd ruta/a/este/repo
chmod +x setup.sh
./setup.sh
```

**Windows:**
```batch
Hacé doble click en setup.bat
```

**2.** Abrí Cursor.

**3.** En el chat de Cursor (Cmd+I o Ctrl+I), escribí directamente:

```
/sdd-new "describí lo que necesitas hacer"
```

Cursor ya reconoce los comandos SDD como agentes nativos. El asistente te va guiando fase por fase.

---

### Perfil C: Uso Antigravity

**1.** Ejecutá el script de instalación (doble click en `setup.bat` en Windows, `./setup.sh` en Linux/macOS).

**2.** En Antigravity, usá el chat de Mission Control con lenguaje natural:

```
quiero hacer un cambio siguiendo SDD: [describí qué necesitas]
```

El asistente arranca el workflow solo.

---

### Perfil D: Solo terminal / OpenCode

**1.** Ejecutá el script de instalación (doble click en `setup.bat` en Windows, `./setup.sh` en Linux/macOS).

**2.** En la terminal, ejecutá:

```bash
opencode
```

**3.** Se abre la interfaz interactiva. Escribí:

```
/sdd-new "describí lo que necesitas hacer"
```

---

## ¿Cómo se usa en el día a día?

### Para un cambio chico (hotfix, corrección rápida)

No necesitás SDD. Describí directamente qué necesitás:

```
"cambiar el color del botón de submit a azul"
```

### Para un cambio mediano/grande (nueva funcionalidad, refactor)

Usá SDD. El workflow completo es:

```
/sdd-nuevo "agregar autenticación por email y contraseña"
```

El asistente te guía por estas fases:

1. **Exploración / Propuesta** — define qué se va a hacer y por qué
2. **Especificación** — describe escenarios concretos de comportamiento
3. **Diseño** — cómo se implementa (arquitectura, datos, módulos)
4. **Tareas** — checklist de implementación
5. **Implementación** — escribe el código
6. **Verificación** — comprueba que funciona según la spec
7. **Archivo** — cierra el cambio

Cada fase genera documentación automáticamente en la carpeta `openspec/` del proyecto.

### Para ver el progreso de un cambio en curso

```
/sdd-continue
```

### Para verificar que lo implementado cumple con lo especificado

```
/sdd-verify
```

---

## Seguridad

- **OpenCode y Gentle AI corren local**. Tu código no se sube a ningún lado.
- **Modelos gratis**: Zen (incluido en OpenCode) o Gemini Flash. Sin necesidad de API keys.
- **Comandos peligrosos**: el asistente pide confirmación antes de ejecutar `rm -rf`, `git push --force`, etc.
- **Permisos configurables** en `opencode.json`.

Cuando tengan presupuesto para modelos pagos (Claude Sonnet, GPT-4, etc.), se actualiza el archivo `opencode.json` y cada uno recibe la actualización.

---

## Testing

Hoy no tenemos tests automatizados. Con SDD, igual arrancamos:

- Cada spec describe escenarios como "si el usuario no existe → 404"
- Esos escenarios se documentan y quedan en el repo
- Cuando decidamos implementar tests, los casos ya están escritos

El comando `/sdd-verify` ya verifica que el código implemente correctamente los escenarios de la spec.

---

## Preguntas frecuentes

**¿Esto reemplaza al code review humano?**
No. El asistente genera spec, diseño, código y verificación. El humano revisa **cada fase**. El `judgment-day` opcional da una revisión adicional automática.

**¿Genera código perfecto?**
No. Genera código que cumple con la spec. El dev revisa, ajusta, y es responsable.

**¿Funciona sin internet?**
Sí, si configurás un modelo local (como `llama.cpp`). Por defecto usa Zen que necesita conexión.

**¿Y si no me gusta el código que generó?**
Podés pedir cambios, refactors, o directamente editar. Es una herramienta, no un reemplazo.

---

## Mantenimiento

Cuando la configuración del equipo cambie (nuevos skills, modelos pagos, etc.):

1. Actualizás `opencode.json` en este repo
2. Cada dev ejecuta:
   ```bash
   cd ruta/a/este/repo
   cp opencode.json ~/.config/opencode/opencode.json
   ```

---

## Recursos

- [Gentle AI](https://github.com/Gentleman-Programming/gentle-ai) — repo oficial
- [OpenCode](https://opencode.ai) — documentación oficial
