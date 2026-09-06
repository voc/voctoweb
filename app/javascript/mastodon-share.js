function mastodonShare(text, url) {
    const enteredDomain = prompt("Please enter the domain of your mastodon instance, e.g. chaos.social")?.trim();
    if (!enteredDomain) return;

    const domainURL = "https://" + enteredDomain.replace("https://", "");

    const shareURL = new URL(domainURL);
    shareURL.pathname = "/share";
    if (text) shareURL.searchParams.set("text", text);
    if (url) shareURL.searchParams.set("url", url);

    const windowHandle = window.open(shareURL, "_blank");
    if (windowHandle) windowHandle.focus();
}