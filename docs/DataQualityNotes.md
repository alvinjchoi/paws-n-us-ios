# Data Quality Notes

## Known Issues

### Human Images in Dog Database
- Found entry "쿠키" (Cookie) with human face image instead of dog
- This appears to be test data that should be filtered out
- Location: Likes tab, appears as one of the liked "dogs"

## Recommendations
1. Add server-side validation to ensure only dog images are uploaded
2. Implement image classification to detect and filter non-dog images
3. Add admin tools to review and remove inappropriate entries
4. Consider using ML models to verify images contain dogs before accepting them

## Temporary Solutions
- Manual review and removal of non-dog entries
- Add reporting feature for users to flag inappropriate content