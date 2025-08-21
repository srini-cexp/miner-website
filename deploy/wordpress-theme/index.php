<?php
/**
 * Main template file for Miner Website WordPress theme
 */

get_header(); ?>

<div id="primary" class="content-area">
    <main id="main" class="site-main">
        
        <?php if (is_home() || is_front_page()): ?>
            <!-- Include the original static website content -->
            <?php include(get_template_directory() . '/static-content.php'); ?>
        <?php else: ?>
            <!-- WordPress content for other pages -->
            <div class="wordpress-content">
                <?php
                if (have_posts()) :
                    while (have_posts()) :
                        the_post();
                        ?>
                        <article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
                            <header class="entry-header">
                                <h1 class="entry-title"><?php the_title(); ?></h1>
                            </header>
                            
                            <div class="entry-content">
                                <?php the_content(); ?>
                            </div>
                        </article>
                        <?php
                    endwhile;
                else :
                    ?>
                    <p><?php _e('Sorry, no posts matched your criteria.'); ?></p>
                    <?php
                endif;
                ?>
            </div>
        <?php endif; ?>
        
    </main>
</div>

<?php get_footer(); ?>
