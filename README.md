# AlzSupport

AlzSupport is a mobile application designed to provide support for families and caregivers of Alzheimer's disease patients. It offers various functionalities to assist users in managing reminders and keeping track of important information, related to their loved ones as well as tracking their location in real time.

## Additional Info

For more info on how the app works check out the video link down below (the explanation is in Macedonian, but you can visually see how all the dependencies are meant to work): 
https://www.youtube.com/watch?v=k6B0Ey1QpZE

## Features

![Simulator Screen Shot - iPhone 11 - 2024-03-10 at 19 31 36](https://github.com/schrodingerisdead/AlzSupport/assets/63170223/b6dddd21-1bc4-4f55-a930-d1e9f703a9f6)

### User Registration

- **Family Members Registration**: Family members can register accounts using their email and password. They can provide additional information such as their name and the email of the patient they are caring for.

- **Patient Registration**: Caregivers can register patient accounts, providing essential details such as name, email, password, relative's email, and birthdate.
  ![Simulator Screen Shot - iPhone 11 - 2024-03-10 at 19 37 12](https://github.com/schrodingerisdead/AlzSupport/assets/63170223/eb2e9273-252c-4443-8daf-b31970f13b89)


### Reminders

- **Add Reminders**: Users can add reminders for medications, appointments, or other important events related to patient care.

- **View Reminders**: Reminders are displayed in a list format, showing the reminder text and current status (e.g., completed or pending).

- **Remove Reminders**: Users can delete reminders that are no longer needed. Deletion of reminders updates the list dynamically.

### Firebase Integration

- **Realtime Database**: AlzSupport utilizes Firebase Realtime Database to store user authentication data, patient information, and reminders. This ensures seamless synchronization across devices.

### User Authentication

- **Secure Login**: Users can securely log in to their accounts using email and password authentication provided by Firebase Authentication.
   ![Simulator Screen Shot - iPhone 11 - 2024-03-10 at 19 35 00](https://github.com/schrodingerisdead/AlzSupport/assets/63170223/e4aef1a1-4847-4774-8472-15e76bdf8c87)

## Getting Started

To run the AlzSupport app locally, follow these steps:

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Ensure you have the necessary Firebase configuration files and dependencies installed.
4. Build and run the app on a simulator or physical device.

## Dependencies

- Firebase/Auth: For user authentication.
- Firebase/Database: For storing user data, patient information, and reminders.

## Contributing

Contributions to AlzSupport are welcome! If you find any bugs or have suggestions for new features, please open an issue or submit a pull request.

