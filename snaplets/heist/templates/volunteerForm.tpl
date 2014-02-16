<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8' />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    <meta name="description" content="RSAC Convention Volunteer Sign Up" />
    <link rel="shortcut icon" type="image/x-icon" href="https://restorethefourthsf.com/wp-content/uploads/2013/06/favicon.ico"/>

    <link rel="stylesheet" type="text/css" media="screen" href="../SafeSignUp/stylesheets/stylesheet.css">

    <!--<script src="builds/converse.min.js"></script>-->
    <title>RSA Convention Volunteer Sign Up</title>
</head>
<body>
    <!-- HEADER -->
    <div id="header_wrap" class="outer">
    <header class="inner">
               <img src="../SafeSignUp/img/pic-10sfbay1.png" href="https://restorethefourthsf.com" alt="Restore the Fourth" style="width:140px;"/> <h1 id="project_title">RSAC Convention Volunteer Sign Up</h1>

    <p>Volunteers signed up: <count>0</count> </p>
    </header>
    </div>

    <div id="main_content_wrap" class="outer">
    <section id="main_content" class="inner">

<h3>What are you volunteering for?</h3>

<p>On Feb 25th, 26th and 27th, roughly 20,000 attendees to the RSA convention will descend on San Francisco to hawk their wares. We will be standing on the streets around Moscone Center during the morning and lunch time asking attendees to join us in condeming RSA's abuse of their customers trust by selling software made insecure at the request of the NSA.</p> 

<p> We will be asking attendees to wear badge ribbons with the text. " I Support the 4th" or "RSA Sold Us Out" and distributing a flyer describing RSA's misdeeds. </p> <img src="../SafeSignUp/img/BadgeRibbon.png"/>

<h3> What did RSA do?</h3>
<p>RSA is creator a widely used cryptography library called BSAFE. From 2004-2011, the default settings on that library were insecure from the NSA. Customers of RSA were delivering their secrets to NSA unwittingly when they believed they were buying secure communications software. Reuters obtained the contract that shows that the NSA specified an random number generator called Dual_EC_DRBG and paid $10 million to RSA for this to be the default.</p>


<h3>Protections for volunteers</h3>

<p>We've attempted to protect our users by encrypting Volunteer data both over the wire and at rest from this form. This form is only served over a TLS connection. User data is the encrypted in the database. Decryption of volunteer data will only occur on devices in the personal possession of the organizers. See the source code on <a href="https://github.com/zmanian/SafeSignUp/">Github</a>.</p>



<dfForm action="/RSACform">
    <dfChildErrorList />

    <dfLabel ref="alias">Alias </dfLabel>
    <dfInputText ref="alias" />
    <br>

    <dfLabel ref="phone_number">Phone Number</dfLabel>
    <dfInputText ref="phone_number" />
    <br>

    <dfLabel ref="email">Email</dfLabel>
    <dfInputText ref="email" />
    <br>

    <dfLabel ref="Feb_24th_Night">Available Feb 24th Night?</dfLabel>
    <dfInputSelect ref="Feb_24th_Night" />
    <br>

    <dfLabel ref="Feb_25th_Morning">Available Feb 25th Morning?</dfLabel>
    <dfInputSelect ref="Feb_25th_Morning" />
    <br>

    <dfLabel ref="Feb_25th_Lunch">Available Feb 25th Lunch?</dfLabel>
    <dfInputSelect ref="Feb_25th_Lunch" />
    <br>

    <dfLabel ref="Feb_26th_Morning">Available Feb 26th Morning?</dfLabel>
    <dfInputSelect ref="Feb_26th_Morning" />
    <br>

    <dfLabel ref="Feb_26th_Lunch">Available Feb 26th Lunch?</dfLabel>
    <dfInputSelect ref="Feb_26th_Lunch" />
    <br>

    <dfInputSubmit value="Enter" />
</dfForm>
</section>
</div>
</body>
</html>