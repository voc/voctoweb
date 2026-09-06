let currentTheme = localStorage.getItem('color-theme') || 'system';

function toggleTheme(newTheme) {
    localStorage.setItem('color-theme', newTheme);
    document.documentElement.classList.toggle('dark', newTheme === 'dark');
    document.documentElement.classList.toggle('light', newTheme === 'light');
    currentTheme = newTheme;
}
toggleTheme(currentTheme);
