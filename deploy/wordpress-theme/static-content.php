<?php
/**
 * Static content integration for the original miner website
 */

// Get the original HTML content and adapt it for WordPress
$original_html_path = get_template_directory() . '/../../index.html';

if (file_exists($original_html_path)) {
    $content = file_get_contents($original_html_path);
    
    // Extract the body content (remove head, html tags)
    preg_match('/<body[^>]*>(.*?)<\/body>/is', $content, $matches);
    $body_content = isset($matches[1]) ? $matches[1] : $content;
    
    // Replace relative paths with WordPress theme paths
    $theme_uri = get_template_directory_uri() . '/../..';
    $body_content = str_replace('src="public/', 'src="' . $theme_uri . '/public/', $body_content);
    $body_content = str_replace('href="public/', 'href="' . $theme_uri . '/public/', $body_content);
    $body_content = str_replace('src="locales/', 'src="' . $theme_uri . '/locales/', $body_content);
    $body_content = str_replace('href="locales/', 'href="' . $theme_uri . '/locales/', $body_content);
    
    // Output the adapted content
    echo $body_content;
} else {
    // Fallback content if original HTML is not found
    ?>
    <div class="miner-website-fallback">
        <h1>Miner Website</h1>
        <p>Welcome to the Miner Website. The original static content could not be loaded.</p>
        <p>Please ensure the static files are properly deployed to the theme directory.</p>
    </div>
    <?php
}
?>
