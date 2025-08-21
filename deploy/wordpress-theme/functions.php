<?php
/**
 * Functions and definitions for Miner Website WordPress theme
 */

// Theme setup
function miner_website_setup() {
    // Add theme support for various features
    add_theme_support('post-thumbnails');
    add_theme_support('title-tag');
    add_theme_support('custom-logo');
    add_theme_support('html5', array(
        'search-form',
        'comment-form',
        'comment-list',
        'gallery',
        'caption',
    ));
}
add_action('after_setup_theme', 'miner_website_setup');

// Enqueue styles and scripts
function miner_website_scripts() {
    // Enqueue the original CSS files
    wp_enqueue_style('miner-website-index', get_template_directory_uri() . '/../../index.css', array(), '1.0.0');
    wp_enqueue_style('miner-website-style', get_template_directory_uri() . '/../../style.css', array(), '1.0.0');
    wp_enqueue_style('miner-website-theme', get_stylesheet_uri(), array(), '1.0.0');
    
    // Enqueue external fonts and animations
    wp_enqueue_style('animate-css', 'https://unpkg.com/animate.css@4.1.1/animate.css', array(), '4.1.1');
    wp_enqueue_style('google-fonts-lato', 'https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&display=swap', array(), null);
}
add_action('wp_enqueue_scripts', 'miner_website_scripts');

// Register navigation menus
function miner_website_menus() {
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'miner-website'),
        'footer' => __('Footer Menu', 'miner-website'),
    ));
}
add_action('init', 'miner_website_menus');

// Add custom post types if needed
function miner_website_custom_post_types() {
    // Example: Mining updates post type
    register_post_type('mining_updates', array(
        'labels' => array(
            'name' => __('Mining Updates'),
            'singular_name' => __('Mining Update'),
        ),
        'public' => true,
        'has_archive' => true,
        'supports' => array('title', 'editor', 'thumbnail', 'excerpt'),
        'menu_icon' => 'dashicons-hammer',
    ));
}
add_action('init', 'miner_website_custom_post_types');

// Customize WordPress admin
function miner_website_admin_customization() {
    // Remove unnecessary admin menu items
    remove_menu_page('edit-comments.php');
}
add_action('admin_menu', 'miner_website_admin_customization');

// Add custom fields for homepage customization
function miner_website_customize_register($wp_customize) {
    // Add section for miner website settings
    $wp_customize->add_section('miner_website_settings', array(
        'title' => __('Miner Website Settings'),
        'priority' => 30,
    ));
    
    // Add setting for enabling/disabling static content
    $wp_customize->add_setting('show_static_content', array(
        'default' => true,
        'sanitize_callback' => 'wp_validate_boolean',
    ));
    
    $wp_customize->add_control('show_static_content', array(
        'label' => __('Show Static Website Content'),
        'section' => 'miner_website_settings',
        'type' => 'checkbox',
    ));
}
add_action('customize_register', 'miner_website_customize_register');

// Security enhancements
function miner_website_security() {
    // Remove WordPress version from head
    remove_action('wp_head', 'wp_generator');
    
    // Remove RSD link
    remove_action('wp_head', 'rsd_link');
    
    // Remove Windows Live Writer
    remove_action('wp_head', 'wlwmanifest_link');
    
    // Remove shortlink
    remove_action('wp_head', 'wp_shortlink_wp_head');
}
add_action('init', 'miner_website_security');

// Performance optimizations
function miner_website_performance() {
    // Remove query strings from static resources
    function remove_query_strings($src) {
        $parts = explode('?', $src);
        return $parts[0];
    }
    add_filter('script_loader_src', 'remove_query_strings', 15, 1);
    add_filter('style_loader_src', 'remove_query_strings', 15, 1);
}
add_action('init', 'miner_website_performance');
?>
