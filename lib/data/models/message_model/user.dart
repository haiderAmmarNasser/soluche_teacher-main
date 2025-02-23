class User {
	int? id;
	String? firstName;
	String? lastName;
	String? gender;
	String? email;
	String? fcmId;
	String? deviceType;
	dynamic emailVerifiedAt;
	String? mobile;
	String? image;
	String? dob;
	dynamic currentAddress;
	String? permanentAddress;
	int? status;
	int? resetRequest;

	User({
		this.id, 
		this.firstName, 
		this.lastName, 
		this.gender, 
		this.email, 
		this.fcmId, 
		this.deviceType, 
		this.emailVerifiedAt, 
		this.mobile, 
		this.image, 
		this.dob, 
		this.currentAddress, 
		this.permanentAddress, 
		this.status, 
		this.resetRequest, 
	});

	@override
	String toString() {
		return 'User(id: $id, firstName: $firstName, lastName: $lastName, gender: $gender, email: $email, fcmId: $fcmId, deviceType: $deviceType, emailVerifiedAt: $emailVerifiedAt, mobile: $mobile, image: $image, dob: $dob, currentAddress: $currentAddress, permanentAddress: $permanentAddress, status: $status, resetRequest: $resetRequest)';
	}

	factory User.fromJson(Map<String, dynamic> json) => User(
				id: json['id'] as int?,
				firstName: json['first_name'] as String?,
				lastName: json['last_name'] as String?,
				gender: json['gender'] as String?,
				email: json['email'] as String?,
				fcmId: json['fcm_id'] as String?,
				deviceType: json['device_type'] as String?,
				emailVerifiedAt: json['email_verified_at'] as dynamic,
				mobile: json['mobile'] as String?,
				image: json['image'] as String?,
				dob: json['dob'] as String?,
				currentAddress: json['current_address'] as dynamic,
				permanentAddress: json['permanent_address'] as String?,
				status: json['status'] as int?,
				resetRequest: json['reset_request'] as int?,
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'first_name': firstName,
				'last_name': lastName,
				'gender': gender,
				'email': email,
				'fcm_id': fcmId,
				'device_type': deviceType,
				'email_verified_at': emailVerifiedAt,
				'mobile': mobile,
				'image': image,
				'dob': dob,
				'current_address': currentAddress,
				'permanent_address': permanentAddress,
				'status': status,
				'reset_request': resetRequest,
			};
}
