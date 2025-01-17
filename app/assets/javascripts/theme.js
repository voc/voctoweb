let currentTheme = localStorage.getItem('theme') || 'light';

function toggleTheme(theme) {
    const newTheme = theme || (currentTheme === 'light' ? 'dark' : 'light');
    localStorage.setItem('theme', newTheme);
    document.documentElement.classList.toggle('dark', newTheme === 'dark');
    currentTheme = newTheme;
}

toggleTheme(currentTheme);