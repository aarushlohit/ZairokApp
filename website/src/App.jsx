import React from 'react';

const downloads = {
  appStore: 'https://example.com/aarush-app-store.apk',
  directApk: 'https://example.com/zairok.apk',
  webFallback: 'https://zairok.app/download'
};

const timeline = [
  {
    title: 'Launch plan announced',
    date: 'August 12, 2025',
    detail: 'Zairok was set to ship with 250+ free AI tools and a brand-new AI studio.'
  },
  {
    title: 'Play Store declined',
    date: 'Before launch',
    detail: 'We pivoted fast with a direct download path and our own installer.'
  },
  {
    title: 'Aarush App Store live',
    date: 'Now',
    detail: 'A lightweight installer to keep Zairok updates moving.'
  }
];

const features = [
  {
    title: 'Instant discovery',
    body: 'One tap access to the full Zairok AI toolbox, curated for creators and builders.'
  },
  {
    title: 'Secure distribution',
    body: 'Aarush App Store keeps you updated even without Play Store access.'
  },
  {
    title: 'Zero login friction',
    body: 'No accounts. Just your name and a welcome screen to get started.'
  }
];

const downloadsList = [
  {
    title: 'Get the Aarush App Store',
    note: 'Recommended — installs and updates Zairok automatically.',
    href: downloads.appStore,
    cta: 'Download Installer'
  },
  {
    title: 'Direct Zairok APK',
    note: 'Manual install for quick access.',
    href: downloads.directApk,
    cta: 'Download Zairok'
  },
  {
    title: 'Web fallback',
    note: 'Use Zairok in your browser while the download finishes.',
    href: downloads.webFallback,
    cta: 'Open Web App'
  }
];

export default function App() {
  return (
    <div className="page">
      <header className="hero">
        <nav className="nav">
          <div className="logo">
            <span className="logo-dot" />
            Zairok Launch Hub
          </div>
          <div className="nav-actions">
            <a href="#downloads" className="ghost">
              Download
            </a>
            <a href="#app-store" className="primary">
              Aarush App Store
            </a>
          </div>
        </nav>
        <div className="hero-grid">
          <div>
            <p className="eyebrow">Launch update</p>
            <h1>
              Zairok was ready for <span>August 12, 2025</span> — but Play Store said no.
            </h1>
            <p className="hero-copy">
              We moved fast. Meet the Aarush App Store installer and new direct download options to
              keep the Zairok journey moving.
            </p>
            <div className="hero-cta">
              <a className="primary" href={downloads.appStore}>
                Download Aarush App Store
              </a>
              <a className="secondary" href={downloads.directApk}>
                Get Zairok APK
              </a>
            </div>
            <p className="hero-note">
              No login required. Just install, say hello, and start exploring Zairok.
            </p>
          </div>
          <div className="hero-card">
            <h3>What you get now</h3>
            <ul>
              <li>✅ Fresh installer to bypass Play Store rejection.</li>
              <li>✅ Two download options for Zairok.</li>
              <li>✅ A welcome onboarding with your name.</li>
              <li>✅ Ongoing updates delivered through Aarush App Store.</li>
            </ul>
          </div>
        </div>
      </header>

      <section className="section" id="timeline">
        <div className="section-heading">
          <h2>Launch timeline</h2>
          <p>We are still on track — just with a new route to the community.</p>
        </div>
        <div className="timeline">
          {timeline.map((item) => (
            <article className="timeline-card" key={item.title}>
              <p className="timeline-date">{item.date}</p>
              <h3>{item.title}</h3>
              <p>{item.detail}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section" id="app-store">
        <div className="section-heading">
          <h2>Aarush App Store</h2>
          <p>The lightweight installer built for Zairok fans.</p>
        </div>
        <div className="feature-grid">
          {features.map((feature) => (
            <article key={feature.title} className="feature-card">
              <h3>{feature.title}</h3>
              <p>{feature.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section downloads" id="downloads">
        <div className="section-heading">
          <h2>Choose your download</h2>
          <p>Pick the option that works best for your device today.</p>
        </div>
        <div className="download-grid">
          {downloadsList.map((item) => (
            <article key={item.title} className="download-card">
              <h3>{item.title}</h3>
              <p>{item.note}</p>
              <a className="primary" href={item.href}>
                {item.cta}
              </a>
            </article>
          ))}
        </div>
      </section>

      <section className="section" id="stay-updated">
        <div className="section-heading">
          <h2>Stay updated</h2>
          <p>Share the launch page, grab the installer, and keep Zairok in your pocket.</p>
        </div>
        <div className="cta-banner">
          <div>
            <h3>Ready to explore Zairok?</h3>
            <p>Download the installer or get the APK in seconds.</p>
          </div>
          <div className="cta-actions">
            <a className="secondary" href={downloads.appStore}>
              Aarush App Store
            </a>
            <a className="primary" href={downloads.directApk}>
              Direct APK
            </a>
          </div>
        </div>
      </section>

      <footer className="footer">
        <div>
          <span className="logo-dot" /> Zairok Launch Hub
        </div>
        <p>Built for the Zairok community. Download, install, and stay inspired.</p>
      </footer>
    </div>
  );
}
