# Osama Community Hub — inicio de sesión con Discord (V1)

Esta carpeta convierte la maqueta HTML en el primer esqueleto de una aplicación desplegable:

- Inicio de sesión mediante OAuth2 de Discord.
- Verificación de que la cuenta pertenece a tu servidor configurado.
- Sesión web `HttpOnly` con identificador aleatorio guardado en D1; el token OAuth **no se guarda**.
- Directorio privado de las cuentas que han iniciado sesión en la web.
- Indicador de actividad **en esta web** (no equivale al estado online de Discord).
- Cierre de sesión de la web.

Todavía no incluye lectura/escritura del chat de Discord, lista completa de miembros del servidor, presencia real de Discord ni voz. Eso será una fase posterior y necesitará permisos/una aplicación adecuados.

## Archivos principales

- `public/index.html`: interfaz web.
- `functions/api/auth/login.js`: inicio de OAuth.
- `functions/api/auth/callback.js`: valida el retorno de Discord, comprueba la pertenencia al servidor y crea la sesión.
- `functions/api/auth/logout.js`: cierre de sesión web.
- `functions/api/me.js`: perfil de la sesión actual.
- `functions/api/members.js`: directorio privado de cuentas vinculadas.
- `functions/_utils.js`: cookies, respuestas y utilidades.
- `schema.sql`: tablas de Cloudflare D1.

## Antes de empezar

Necesitas cuentas gratuitas de GitHub y Cloudflare, y acceso al [Discord Developer Portal](https://discord.com/developers/applications). No envíes contraseñas ni `Client Secret` por el chat.

## Paso 1 — Crear una aplicación de Discord

1. Abre el [Discord Developer Portal](https://discord.com/developers/applications) y pulsa **New Application**.
2. Ponle un nombre para identificar la integración de la web, por ejemplo `Osama Community Hub`.
3. En **OAuth2**, guarda el `Client ID`. Después podremos copiar el `Client Secret` y guardarlo directamente como secreto en Cloudflare.
4. En los ajustes del servidor de Discord, activa **Ajustes de usuario → Avanzado → Modo desarrollador**. Después haz clic derecho en el icono de tu servidor y elige **Copiar ID del servidor**. Ese será `DISCORD_GUILD_ID`.

No necesitas crear ni invitar un bot para esta primera fase de inicio de sesión. El scope OAuth `guilds.members.read` se usa para verificar que la persona autenticada pertenece al servidor configurado.

## Paso 2 — Subir el proyecto a GitHub

1. Crea un repositorio nuevo en [GitHub](https://github.com/). Para mantener la web privada mientras la desarrollas, no publiques contenido privado real en el repositorio. Este prototipo no incluye secretos.
2. Descomprime esta carpeta y sube **su contenido** al nivel raíz del repositorio; debes ver las carpetas `public` y `functions`, además de `schema.sql` y `README.md`.
3. No subas `.dev.vars`, tokens, contraseñas ni el Client Secret.

## Paso 3 — Publicar una primera vez en Cloudflare Pages

1. Abre [Cloudflare Dashboard](https://dash.cloudflare.com/) → **Workers & Pages** → **Create** → **Pages** y conecta el repositorio de GitHub.
2. Elige **None** como framework preset. Deja vacío el comando de compilación y usa `public` como **Build output directory**.
3. Publica el primer despliegue. Cloudflare te dará una URL similar a `https://nombre-del-proyecto.pages.dev`.

Las funciones de `functions/` se desplegarán como Pages Functions junto al HTML.

## Paso 4 — Registrar la URL OAuth exacta en Discord

En **Developer Portal → tu aplicación → OAuth2 → Redirects**, añade esta URL, sustituyendo el nombre del proyecto por el real:

`https://NOMBRE-REAL.pages.dev/api/auth/callback`

Copia exactamente esa misma URL para el ajuste `DISCORD_REDIRECT_URI` en Cloudflare. Es importante que coincidan protocolo, dominio y ruta.

## Paso 5 — Crear D1 y cargar el esquema

1. En Cloudflare Dashboard abre **Workers & Pages → D1 SQL Database** (la sección puede aparecer simplemente como **D1**), crea una base de datos llamada `osama-community`.
2. Abre la consola SQL de esa base de datos y ejecuta todo el contenido de `schema.sql`.
3. En tu proyecto Pages, abre **Settings → Bindings → Add → D1 database binding**.
4. Pon exactamente `DB` como **Variable name** y selecciona la base de datos `osama-community`.
5. Guarda los cambios.

## Paso 6 — Configurar variables y secretos

En el proyecto Pages, abre **Settings → Variables and Secrets**. Añade en el entorno **Production**:

Variables normales:

- `DISCORD_CLIENT_ID` = el Client ID de tu aplicación.
- `DISCORD_REDIRECT_URI` = `https://NOMBRE-REAL.pages.dev/api/auth/callback`.
- `DISCORD_GUILD_ID` = el ID numérico de tu servidor.

Secreto cifrado:

- `DISCORD_CLIENT_SECRET` = el Client Secret de la aplicación de Discord. Añádelo como **Secret**, no como variable de texto público.

Guarda y vuelve a desplegar para que las Functions reciban la configuración.

## Paso 7 — Probar

1. Abre la URL `pages.dev` del proyecto.
2. Pulsa **Entrar con Discord** y autoriza los permisos solicitados.
3. Si la cuenta pertenece al servidor configurado, volverás a la web con tu avatar y nombre. Tu cuenta aparecerá en **Miembros**.
4. Cierra sesión y verifica que ya no puedes ver el directorio privado.
5. Pide a otro amigo que haga lo mismo cuando esté listo.

Si algo falla, revisa que la URL de redirección sea idéntica en Discord y Cloudflare, que `DB` esté enlazada y que `schema.sql` se haya ejecutado.

## Privacidad y alcance de esta versión

- Esta versión almacena ID de Discord, nombre, apodo, avatar y marcas de tiempo de inicio/actividad web en D1.
- El token OAuth solo se usa en el callback para obtener el perfil y comprobar la pertenencia; **no se almacena en la base de datos**.
- La cookie de sesión es `HttpOnly`, `SameSite=Lax`, `Secure` en HTTPS y expira en siete días.
- El directorio muestra solo cuentas que ya han iniciado sesión, no todos los miembros del servidor.
- “Ahora en la web” significa actividad reciente en esta página. No revela la presencia real en Discord.
- El botón de cerrar sesión termina la sesión de esta web. Si quieres revocar también la autorización de la aplicación, hazlo desde Discord → Ajustes de usuario → Aplicaciones autorizadas.
