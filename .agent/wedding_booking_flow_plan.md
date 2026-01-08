# Wedding Booking Flow - Implementation Plan

## Overview
Complete wedding booking flow from package selection to final confirmation with location selection.

## User Flow

### 1. Package Selection
- User selects "Wedding Services" from service types
- Display list of wedding packages
- Each package card shows:
  - Package image
  - Package name
  - Price (updates dynamically if customized)
  - Duration
  - "Show Details" button
  - "Select" button

### 2. Package Details Modal (customize_package_sheet.dart)
**Current Features:**
- Header with package image and info
- Included Services list (with bullet points)
- Expert Staff Members
- Package Pricing card
- Bottom buttons: Close and Confirm

**Required Updates:**
- Change "Confirm" to "Save & Continue"
- Add bottom navigation bar showing:
  - Total price (left side)
  - "Continue" button (right side)
- Save Changes functionality
- Real-time price/duration updates

### 3. Date & Time Selection
**After clicking "Continue" from package details:**
- Navigate to Date & Time selection screen
- Show selected package context
- Calendar for date selection
- Time slots for time selection
- "Next" button at bottom

### 4. Booking Type Modal
**After selecting date & time:**
- Modal with two options:
  - "At Salon" - with salon icon
  - "At Place" - with location icon
- User selects booking location type

### 5A. At Salon Flow
**If "At Salon" selected:**
- Continue with regular salon booking flow
- Show booking summary
- Proceed to payment

### 5B. At Place Flow
**If "At Place" selected:**
- Navigate to Map Picker screen
- User selects location on map
- Confirm address
- Show booking summary with address

### 6. Final Confirmation Modal
**Before payment:**
- Package summary
- Selected services
- Assigned staff
- Date & Time
- Location (Salon or Custom Address)
- Total Price
- Total Duration
- "Confirm Booking" button

## Files to Create/Modify

### New Files
1. `lib/view/wedding_booking_type_modal.dart` - Booking type selection
2. `lib/view/wedding_date_time_screen.dart` - Date/time with wedding context
3. `lib/view/wedding_booking_summary_modal.dart` - Final confirmation

### Files to Modify
1. `lib/view/widgets/salon_details/customize_package_sheet.dart`
   - Update bottom buttons
   - Add "Save & Continue" functionality
   - Improve price calculation display

2. `lib/controller/salon_details_controller.dart`
   - Add wedding booking state
   - Add selected date/time storage
   - Add booking type storage
   - Add selected address storage

3. `lib/view/widgets/salon_details/wedding_package_list.dart`
   - Ensure proper package selection flow

## State Management

### Controller Properties to Add
```dart
// Wedding booking state
DateTime? selectedWeddingDate;
String? selectedWeddingTime;
String? weddingBookingType; // 'salon' or 'place'
Map<String, dynamic>? selectedAddress;
WeddingPackage? activeWeddingPackage;
```

### Controller Methods to Add
```dart
void setWeddingDate(DateTime date);
void setWeddingTime(String time);
void setBookingType(String type);
void setWeddingAddress(Map<String, dynamic> address);
void proceedToWeddingDateSelection();
void proceedToBookingTypeSelection();
void proceedToAddressSelection();
double getWeddingPackageTotalPrice(WeddingPackage package);
String getWeddingPackageTotalDuration(WeddingPackage package);
```

## UI Components

### Package Details Modal Updates
- **Header**: Package image with gradient overlay
- **Services Section**: 
  - Simple bullet list
  - "Added" badges for extra services
  - Edit icon to add more services
- **Staff Section**: Horizontal scrollable list
- **Pricing Card**: 
  - Original price (strikethrough)
  - Savings badge
  - Final price (large, bold)
- **Bottom Bar**:
  - Left: Total price display
  - Right: "Continue" button

### Booking Type Modal
- **Design**: Bottom sheet modal
- **Options**:
  - At Salon card (icon + text)
  - At Place card (icon + text)
- **Styling**: Cards with hover/tap effects

### Date & Time Screen
- **Header**: Package name and price
- **Calendar**: Month view with selectable dates
- **Time Slots**: Grid of available times
- **Bottom**: "Next" button

### Final Summary Modal
- **Sections**:
  - Package info card
  - Services list
  - Staff list
  - Date & Time card
  - Location card
  - Price breakdown
- **Bottom**: "Confirm Booking" button

## Navigation Flow

```
Wedding Services Selected
  ↓
Package List
  ↓
[Show Details] → Package Details Modal
  ↓
[Save & Continue] → Close Modal
  ↓
[Continue Button] → Date & Time Screen
  ↓
[Next] → Booking Type Modal
  ↓
[At Salon] → Booking Summary → Payment
  ↓
[At Place] → Map Picker → Booking Summary → Payment
```

## Implementation Priority

1. ✅ Fix current package customization (DONE)
2. 🔄 Update package details modal bottom bar
3. 🔄 Add wedding booking state to controller
4. 🔄 Create booking type modal
5. 🔄 Create wedding date/time screen
6. 🔄 Create booking summary modal
7. 🔄 Wire up navigation flow
8. 🔄 Test end-to-end flow

## Design Principles

- **Consistency**: Use existing color scheme (#4A2C3F purple)
- **Clarity**: Clear labels and visual hierarchy
- **Feedback**: Show loading states and confirmations
- **Accessibility**: Large tap targets, readable text
- **Responsiveness**: Handle different screen sizes

## Next Steps

1. Update customize_package_sheet.dart with new bottom bar
2. Add wedding booking state to controller
3. Create booking type modal
4. Create date/time screen
5. Create summary modal
6. Wire everything together
