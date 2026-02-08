import React, { useState, useEffect } from 'react';
import './styles.css';

const features = [
  {
    title: 'Explore 250+ Free AI Tools',
    description: 'Curated collection of the best free AI tools for students, developers, designers, and creators.'
  },
  {
    title: 'Smart Categorization',
    description: 'Organized by categories like Chat, Image Generation, Code, Writing, and more for easy discovery.'
  },
  {
    title: 'Built-in AI Chat',
    description: 'Integrated AI chat powered by advanced models for conversations, questions, and assistance.'
  },
  {
    title: 'AI Image Generation',
    description: 'Create images with AI using concise prompts and presets.'
  },
  {
    title: 'Bookmark Your Favorites',
    description: 'Save your preferred tools and access them quickly from your collection.'
  },
  {
    title: 'No Paywalls, No Ads',
    description: 'Free access to tools and features without interruptions or hidden costs.'
  }
];

const communityMessage = {
  title: 'Zairok is Open Source and Community Driven',
  content: 'If Zairok goes viral, the probability is very high that we will bring: New powerful features, More AI tools and categories, File upload support in AI chat, New image generation models, Advanced AI capabilities, Deeper tool discovery and digging. Right now we list 250+ free AI tools, and we are just getting started. More users = more motivation = faster growth. Our only motivation to build and improve Zairok is YOU.',
  cta: 'Join the Community'
};

const developerBio = {
  name: 'Lohit (Aarush Lohit)',
  title: 'Author | Lyricist | Coder| CEO | Founder',
  age: '17',
  story: 'Turned Criticism into hard work. Zairok is proof that resilience builds better tools — not for fame, but to show up. Not to impress, but to express.',
  cta: 'See the Vision'
};

export default function App() {
  const [theme, setTheme] = useState('light');
  const [downloads, setDownloads] = useState(1); // Initial base count set to 1

  useEffect(() => {
    const savedDownloads = localStorage.getItem('zairok_downloads');
    if (!savedDownloads || savedDownloads !== '1') {
      setDownloads(50);
      localStorage.setItem('zairok_downloads', '1');
    } else {
      setDownloads(50);
    }
  }, []);

  const handleDownload = () => {
    const newCount = downloads + 1;
    setDownloads(newCount);
    localStorage.setItem('zairok_downloads', newCount.toString());
  };

  const toggleTheme = () => {
    setTheme(theme === 'light' ? 'dark' : 'light');
    document.documentElement.setAttribute('data-theme', theme === 'light' ? 'dark' : 'light');
  };

  return (
    <div className="app" data-theme={theme}>
      <header className="header">
        <nav className="nav">
          <div className="logo">
            <div className="logo-"></div>
            Zairok.
          </div>

          <div className="nav-actions">
            <button className="theme-toggle" onClick={toggleTheme}>
              {theme === 'light' ? '🌙' : '☀️'}
            </button>
          </div>
        </nav>
      </header>

      <main className="main">
        <section className="hero-section">
          <div className="container">
            <div className="hero-content">
              <span className="section-tag">Premium AI Platform</span>
              <h1 className="hero-title">
                Your Destination for <span className="highlight">Free AI Tools</span>
              </h1>
              <p className="hero-subtitle">
                Explore, compare, and use 250+ curated AI tools. Built-in AI chat and image generation — all free, no ads, no paywalls.
              </p>
              <div className="hero-ctas">
                <a href="https://github.com/aarushlohit/ZairokApp/releases/download/Release/zairokapp.apk" className="btn btn-primary" onClick={handleDownload}>Download Zairok APK</a>
                <a href="https://github.com/aarushlohit/ZairokApp/releases/download/Release/aarushappstore.apk" className="btn btn-secondary" onClick={handleDownload}>Aarush App Store</a>
              </div>
              <div className="download-counter">
                <span className="counter-icon">🔥</span>
                <span className="counter-text">{downloads.toLocaleString()} downloads so far!</span>
              </div>
            </div>
          </div>
        </section>

        <section className="features-section" id="features">
          <div className="container">
            <div className="section-header">
              <span className="section-tag">Features</span>
              <h2>Why Choose Zairok?</h2>
              <p>Everything you need for AI exploration in one premium, high-performance platform</p>
            </div>
            <div className="features-grid">
              {features.map((feature, index) => (
                <div key={index} className="feature-card">
                  <div className="feature-dot" aria-hidden="true" />
                  <h3>{feature.title}</h3>
                  <p>{feature.description}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="community-section">
          <div className="container">
            <div className="community-banner">
              <div className="community-content">
                <span className="section-tag">Community First</span>
                <h2>{communityMessage.title}</h2>
                <p>{communityMessage.content}</p>
                <button className="btn btn-primary">{communityMessage.cta}</button>
              </div>
              <div className="stat-grid">
                <div className="stat-item">
                  <span className="stat-number">{downloads.toLocaleString()}</span>
                  <span className="stat-label">Total Downloads</span>
                </div>
                <div className="stat-item">
                  <span className="stat-number">100%</span>
                  <span className="stat-label">Free Forever</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="developer-section" id="about">
          <div className="container">
            <div className="developer-card">
              <div className="developer-header">
                <img src='https://avatars.githubusercontent.com/u/141929019?v=4' alt="Lohit" className="dev-avatar" />
                <div className="dev-info">
                  <h3>{developerBio.name}</h3>
                  <p className="dev-title">{developerBio.title}</p>
                  <p className="dev-age">Age {developerBio.age} • Indie Developer</p>
                </div>
              </div>
              <p className="dev-story">{developerBio.story}</p>
              <div className="launch-note">
                <strong>App Store Update:</strong> After Google Play declined our release in Aug 2025, we finally built our own launcher. The Aarush App Store is live!
              </div>
              <div className="dev-message">"I define myself."</div>
            </div>
          </div>
        </section>
       
      </main>

      <footer className="footer">
        <div className="container">
          <div className="footer-inner">
            <div className="footer-info">
              <div className="footer-logo">Zairok</div>
              <p className="footer-tagline">Built by the community, for the community. Open source and free forever.</p>
            </div>

            <nav className="footer-nav" aria-label="Footer">
              <a href="#features">Features</a>
              <a href="#about">About</a>
              <a href="mailto:zairokcare@gmail.com">Contact</a>
            </nav>
          </div>
        </div>
      </footer>
    </div>
  );
}
