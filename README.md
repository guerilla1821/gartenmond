# Gartenmond auf GitHub Pages

Pflegeplan für euren Garten nach Jahreszeit und Mondkalender. Die App läuft als statische Seite auf GitHub Pages, Daten und Login liegen bei Supabase (kostenlose Stufe reicht).

Dauer der Einrichtung: etwa 30 Minuten.

## Dateien

| Datei | Zweck |
|---|---|
| `index.html` | die App |
| `config.js` | Supabase-Adresse und öffentlicher Schlüssel (musst du ausfüllen) |
| `supabase-setup.sql` | legt Tabellen, Zugriffsregeln und dich als Verwalter an |
| `manifest.webmanifest`, `icon*.png`, `icon.svg` | App-Symbol für den Home-Bildschirm |

## 1. Supabase-Projekt anlegen

1. Auf [supabase.com](https://supabase.com) anmelden und **New project** wählen.
2. Name z. B. `gartenmond`, Region **Frankfurt** oder **Zürich**, ein Datenbank-Passwort vergeben (brauchst du später nicht).
3. Warten, bis das Projekt bereit ist.

## 2. Datenbank einrichten

1. Links **SQL Editor** öffnen, **New query**.
2. Den Inhalt von `supabase-setup.sql` einfügen.
3. In der **letzten Zeile** `DEINE-EMAIL@example.com` durch deine eigene Adresse ersetzen.
4. **Run** klicken. Es sollte „Success“ erscheinen.

## 3. Login per E-Mail einstellen

**Authentication → URL Configuration**

- **Site URL:** `https://guerilla1821.github.io/gartenmond/`
- Unter **Redirect URLs** dieselbe Adresse noch einmal hinzufügen.

**Authentication → Emails → Magic Link** (Vorlage anpassen, damit auch ein Code mitkommt):

```html
<h2>Anmelden bei Gartenmond</h2>
<p><a href="{{ .ConfirmationURL }}">Hier tippen, um dich anzumelden</a></p>
<p>Oder diesen Code in der App eingeben: <strong>{{ .Token }}</strong></p>
```

Den Code braucht ihr vor allem auf dem iPhone: Eine App, die auf dem Home-Bildschirm liegt, teilt ihre Anmeldung nicht mit Safari. Der Link öffnet sich dort in Safari, der Code funktioniert direkt in der App.

## 4. Zweite Person zulassen

Der eingebaute Mailversand von Supabase schickt Mails **nur an Mitglieder eures Supabase-Teams** und höchstens etwa **2 pro Stunde**.

- Einfachster Weg: Im Supabase-Dashboard oben links die Organisation wählen, **Team → Invite**, ihre E-Mail eintragen. Sie muss die Einladung annehmen.
- Alternative: Unter **Authentication → Emails → SMTP Settings** einen eigenen Mailversand eintragen (z. B. Brevo oder Resend, beide haben Gratis-Stufen). Dann gilt die Team-Einschränkung nicht.

Danach in der App unter **Team → Person freischalten** ihre Adresse mit der gewünschten Rolle eintragen.

Rollen:

- **Verwalter:** alles, auch Zonen und Mitglieder
- **Gärtner:** Pflanzen und Aufgaben, Zonen nur ansehen
- **Gast:** nur lesen

Die Regeln gelten in der Datenbank selbst, nicht nur in der Oberfläche.

## 5. `config.js` ausfüllen

Im Dashboard **Project Settings → API** (bzw. **API Keys**):

- **Project URL** bei `url` eintragen
- **anon public** oder **publishable** Key bei `key` eintragen

Dieser Schlüssel ist für die Öffentlichkeit gedacht und darf auf GitHub liegen. **Nie** den `service_role`- oder `secret`-Schlüssel verwenden.

## 6. Auf GitHub Pages veröffentlichen

1. Auf GitHub **New repository**, Name `gartenmond`, Sichtbarkeit **Public** (GitHub Pages ist im Gratis-Konto nur für öffentliche Repositories verfügbar; eure Gartendaten liegen trotzdem geschützt in Supabase).
2. **Add file → Upload files**, alle Dateien aus diesem Ordner hineinziehen, **Commit changes**.
3. **Settings → Pages:** Source „Deploy from a branch“, Branch `main`, Ordner `/ (root)`, **Save**.
4. Nach ein bis zwei Minuten läuft die App unter `https://guerilla1821.github.io/gartenmond/`.

Heißt das Repository anders, passe die Adresse in Schritt 3 entsprechend an.

## 7. Aufs Handy legen

- **iPhone:** Adresse in Safari öffnen → Teilen → **Zum Home-Bildschirm**. In der App mit Code anmelden.
- **Android:** In Chrome öffnen → Menü → **App installieren** bzw. **Zum Startbildschirm hinzufügen**.

Die Anmeldung bleibt gespeichert, ihr müsst euch normalerweise nur einmal pro Gerät anmelden.

## Gut zu wissen

- **Pausierung:** Kostenlose Supabase-Projekte werden nach etwa einer Woche ohne Nutzung pausiert. Die Daten bleiben erhalten. In der App erscheint dann ein Verbindungsfehler; im Supabase-Dashboard genügt ein Klick auf **Restore project**.
- **Änderungen:** Nach jeder Änderung an den Dateien auf GitHub ist die neue Version nach ein bis zwei Minuten online. Auf dem Handy ggf. die App einmal schließen und neu öffnen.
- **Mondberechnung** läuft komplett im Browser, ohne externe Dienste.
