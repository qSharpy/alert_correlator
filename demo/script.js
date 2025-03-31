document.addEventListener('DOMContentLoaded', function() {
    // Get elements
    const slides = document.querySelectorAll('.slide');
    const prevBtn = document.getElementById('prev-btn');
    const nextBtn = document.getElementById('next-btn');
    const slideCounter = document.getElementById('slide-counter');
    
    // Set initial state
    let currentSlide = 0;
    let currentTextChunk = 0;
    updateSlideCounter();
    
    // Create modal for fullscreen images
    createImageModal();
    
    // Event listeners for navigation buttons
    prevBtn.addEventListener('click', showPreviousSlide);
    nextBtn.addEventListener('click', handleNextAction);
    
    // Keyboard navigation
    document.addEventListener('keydown', function(e) {
        if (e.key === 'ArrowRight' || e.key === ' ') {
            handleNextAction();
        } else if (e.key === 'ArrowLeft') {
            showPreviousSlide();
        } else if (e.key === 'Escape') {
            closeModal();
        }
    });
    
    // Make all images clickable for fullscreen view
    setupImageClicks();
    
    // Setup progressive text reveal
    setupProgressiveText();
    
    // Functions to navigate slides
    function handleNextAction() {
        // Check if there are more text chunks to reveal in the current slide
        const currentSlideElement = slides[currentSlide];
        const textChunks = currentSlideElement.querySelectorAll('.text-chunk');
        
        if (textChunks.length > 0 && currentTextChunk < textChunks.length) {
            // Reveal next text chunk
            textChunks[currentTextChunk].classList.add('visible');
            currentTextChunk++;
        } else {
            // Move to next slide if all text chunks are revealed
            if (currentSlide < slides.length - 1) {
                changeSlide(currentSlide + 1);
            }
        }
    }
    
    function showNextSlide() {
        if (currentSlide < slides.length - 1) {
            changeSlide(currentSlide + 1);
        }
    }
    
    function showPreviousSlide() {
        if (currentSlide > 0) {
            changeSlide(currentSlide - 1);
        }
    }
    
    function changeSlide(slideIndex) {
        // Remove active class from current slide
        slides[currentSlide].classList.remove('active');
        
        // Add active class to new slide
        slides[slideIndex].classList.add('active');
        
        // Update current slide index
        currentSlide = slideIndex;
        
        // Reset text chunk counter for the new slide
        currentTextChunk = 0;
        
        // Show first text chunk in the new slide
        const newSlideTextChunks = slides[currentSlide].querySelectorAll('.text-chunk');
        if (newSlideTextChunks.length > 0) {
            newSlideTextChunks[currentTextChunk].classList.add('visible');
            currentTextChunk++;
        }
        
        // Update slide counter
        updateSlideCounter();
        
        // Update button states
        updateButtonStates();
    }
    
    function updateSlideCounter() {
        slideCounter.textContent = `${currentSlide + 1} / ${slides.length}`;
    }
    
    function updateButtonStates() {
        // Disable prev button if on first slide
        prevBtn.disabled = currentSlide === 0;
        
        // Only disable next button if on last slide AND all text chunks are revealed
        const currentSlideElement = slides[currentSlide];
        const textChunks = currentSlideElement.querySelectorAll('.text-chunk');
        const isLastSlide = currentSlide === slides.length - 1;
        const allChunksRevealed = textChunks.length === 0 || currentTextChunk >= textChunks.length;
        
        nextBtn.disabled = isLastSlide && allChunksRevealed;
    }
    
    function setupProgressiveText() {
        // For each slide, find text elements and wrap them in text-chunk divs
        slides.forEach(slide => {
            const textElements = slide.querySelectorAll('p, ul, ol, .description, .key-features, .capability, .code-section, .container-card, .demo-steps, .appendix-section');
            
            textElements.forEach(element => {
                // Skip if already processed or is a parent of other text chunks
                if (!element.classList.contains('text-chunk') &&
                    !element.querySelector('.text-chunk') &&
                    !element.closest('.text-chunk')) {
                    element.classList.add('text-chunk');
                }
            });
            
            // Show first text chunk in the active slide
            if (slide.classList.contains('active')) {
                const firstChunk = slide.querySelector('.text-chunk');
                if (firstChunk) {
                    firstChunk.classList.add('visible');
                    currentTextChunk = 1;
                }
            }
        });
    }
    
    function createImageModal() {
        // Create modal elements
        const modal = document.createElement('div');
        modal.className = 'modal';
        
        const closeBtn = document.createElement('span');
        closeBtn.className = 'close-modal';
        closeBtn.innerHTML = '&times;';
        closeBtn.onclick = closeModal;
        
        const modalImg = document.createElement('img');
        modalImg.className = 'modal-content';
        
        // Append elements to modal
        modal.appendChild(closeBtn);
        modal.appendChild(modalImg);
        
        // Append modal to body
        document.body.appendChild(modal);
        
        // Close modal when clicking outside the image
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal();
            }
        });
    }
    
    function setupImageClicks() {
        const images = document.querySelectorAll('.image-container img');
        
        images.forEach(img => {
            img.addEventListener('click', function() {
                const modal = document.querySelector('.modal');
                const modalImg = document.querySelector('.modal-content');
                
                modal.classList.add('active');
                modalImg.src = this.src;
            });
        });
    }
    
    function closeModal() {
        const modal = document.querySelector('.modal');
        if (modal) {
            modal.classList.remove('active');
        }
    }
    
    // Initial button state update
    updateButtonStates();
});