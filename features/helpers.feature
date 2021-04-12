Feature: Provide helpers and resource items to make multiple targets easy to manage.

  As a software developer
  I want to use helpers and resource items
  In order to enable automatic navigation of items.
  
  Background:
    Given a built app at "middlemac_extras_app"
    
  Scenario:
    The css_image_sizes helper should return CSS for every image in the project
    and @2x images should have proper widths and heights, too.
    When I cd to "build"
    And the file "index.html" should contain "img[src$='/images/middlemac-extras-small.png'] { max-width: 128px; max-height: 128px; }"
    And the file "index.html" should contain "img[src$='/images/middlemac-extras-small@2x.png'] { max-width: 128px; max-height: 128px; }"
    And the file "index.html" should contain "img[src$='/images/middlemac-extras-smaller.png'] { max-width: 64px; max-height: 64px; }"
    

  Scenario:
    The md_images helper should return Markdown references for every image in
    the project.
    When I cd to "build"
    And the file "index.html" should contain '[middlemac-extras-small]: /images/middlemac-extras-small.png'
    And the file "index.html" should contain '[middlemac-extras-small@2x]: /images/middlemac-extras-small@2x.png'
    And the file "index.html" should contain '[middlemac-extras-smaller]: /images/middlemac-extras-smaller.png'
    

  Scenario:
    The md_links helper should return Markdown references for every HTML file
    in the project, and should include a title generated from the front matter.
    When I cd to "build"
    And the file "index.html" should contain '[index]: / "Fixture for middlemac-extras"'
    
  Scenario:
    The extended image tag should include srcset automatically if @2x images are
    present, and not include a srcset if not.
    When I cd to "build"
    And the file "index.html" should contain 'img src="/images/middlemac-extras-small.png" srcset="/images/middlemac-extras-small@2x.png 2x" alt=""'
    And the file "index.html" should contain 'img src="/images/middlemac-extras-smaller.png" alt=""'
